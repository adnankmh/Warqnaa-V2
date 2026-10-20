<?php
namespace App\Services\Commerce;

use Illuminate\Support\Facades\{Cache,Http};

/** Verify the untouched, signed Google callback bytes with Google's EC keys. */
class AdMobSsvVerifier
{
    public const KEYS_URL='https://www.gstatic.com/admob/reward/verifier-keys.json';

    public function verify(string $query): array
    {
        abort_if(strlen($query)>16384 || !preg_match('/^(.+)&signature=([^&]+)&key_id=([0-9]+)$/D',$query,$parts),403,'Invalid SSV signature.');
        $signed=$parts[1];$parameters=[];
        foreach(explode('&',$signed) as $pair) {
            $values=explode('=',$pair,2);$key=rawurldecode($values[0]);
            abort_if(count($values)!==2 || !preg_match('/^[a-z_]+$/D',$key) || array_key_exists($key,$parameters),403,'Invalid SSV parameters.');
            $parameters[$key]=rawurldecode($values[1]);
        }
        foreach(['ad_unit','custom_data','timestamp','transaction_id','user_id'] as $key) abort_if(empty($parameters[$key]),403,'Missing SSV parameter.');
        abort_unless(ctype_digit($parameters['timestamp']) && ctype_digit($parameters['user_id']) && strlen($parameters['transaction_id'])<=128,403,'Invalid SSV identity.');
        abort_if(abs(now()->getTimestampMs()-(int)$parameters['timestamp'])>86400000,403,'Expired SSV callback.');
        $keys=Cache::remember('warqnaa.admob.ssv.keys',now()->addHours(6),function() {
            return Http::timeout(8)->withOptions(['allow_redirects'=>false])->get(self::KEYS_URL)->throw()->json('keys');
        });
        $pem=null;
        foreach((array)$keys as $key) if((string)($key['keyId']??'')===$parts[3]) {$pem=$key['pem']??null;break;}
        abort_unless(is_string($pem),403,'Unknown SSV signing key.');
        $encoded=strtr(rawurldecode($parts[2]),'-_','+/');
        $signature=base64_decode($encoded.str_repeat('=',(4-strlen($encoded)%4)%4),true);
        abort_unless($signature!==false && openssl_verify($signed,$signature,$pem,OPENSSL_ALGO_SHA256)===1,403,'Invalid SSV signature.');
        return $parameters;
    }
}

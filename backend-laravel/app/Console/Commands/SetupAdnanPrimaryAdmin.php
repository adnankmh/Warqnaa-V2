<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class SetupAdnanPrimaryAdmin extends Command
{
    protected $signature='warqnaa:setup-adnan-admin {--force : Apply outside local/testing}';
    protected $description='Provision the Adnan primary administrator without storing a password in source control.';

    public function handle(): int
    {
        $password=(string)env('WARQNAA_ADNAN_ADMIN_PASSWORD',env('WARQNAA_LOCAL_ADMIN_PASSWORD',''));
        $email=trim((string)env('WARQNAA_ADNAN_ADMIN_EMAIL',''));
        if(strlen($password)<8){
            $this->error('Set WARQNAA_ADNAN_ADMIN_PASSWORD to a private password of at least 8 characters.');
            return self::FAILURE;
        }
        if(!filter_var($email,FILTER_VALIDATE_EMAIL)){
            $this->error('Set WARQNAA_ADNAN_ADMIN_EMAIL to the private administrator email.');
            return self::FAILURE;
        }
        foreach([
            'WARQNAA_LOCAL_ADMIN_USERNAME'=>'Adnan',
            'WARQNAA_LOCAL_ADMIN_EMAIL'=>$email,
            'WARQNAA_LOCAL_ADMIN_PASSWORD'=>$password,
        ] as $key=>$value){
            putenv($key.'='.$value);
            $_ENV[$key]=$value;
            $_SERVER[$key]=$value;
        }
        $args=['--single'=>true];
        if($this->option('force')) $args['--force']=true;
        $code=Artisan::call('warqnaa:local-admin-setup',$args);
        $output=trim(Artisan::output());
        if($output!=='') $this->line($output);
        return $code;
    }
}

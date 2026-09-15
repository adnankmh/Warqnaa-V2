<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;

class SetupAdnanPrimaryAdmin extends Command
{
    protected $signature='warqnaa:setup-adnan-admin {--force : Apply outside local/testing}';
    protected $description='Compatibility alias for private environment-driven administrator provisioning.';

    public function handle(): int
    {
        $args=[];
        if($this->option('force')) $args['--force']=true;
        $code=Artisan::call('warqnaa:local-admin-setup',$args);
        $output=trim(Artisan::output());
        if($output!=='') $this->line($output);
        return $code;
    }
}

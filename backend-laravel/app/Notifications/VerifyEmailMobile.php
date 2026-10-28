<?php
namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class VerifyEmailMobile extends Notification
{
    use Queueable;

    public function __construct(private readonly string $url) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $ar = app()->isLocale('ar');
        $username = (string) $notifiable->username;

        return (new MailMessage)
            ->subject($ar ? 'تأكيد بريدك في Warqna' : 'Verify your Warqna email')
            ->greeting($ar ? 'مرحبًا '.$username : 'Hello '.$username)
            ->line($ar
                ? 'اضغط الزر لتأكيد البريد الإلكتروني المرتبط بحساب Warqna.'
                : 'Use the button below to verify the email address linked to your Warqna account.')
            ->action($ar ? 'تأكيد البريد الإلكتروني' : 'Verify email address', $this->url)
            ->line($ar
                ? 'تنتهي صلاحية الرابط تلقائيًا. تجاهل الرسالة إذا لم تطلبها.'
                : 'This link expires automatically. Ignore this message if you did not request it.');
    }
}

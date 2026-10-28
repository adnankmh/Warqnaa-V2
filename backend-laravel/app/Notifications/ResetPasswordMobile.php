<?php
namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordMobile extends Notification
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
            ->subject($ar ? 'إعادة تعيين كلمة مرور Warqna' : 'Reset your Warqna password')
            ->greeting($ar ? 'مرحبًا '.$username : 'Hello '.$username)
            ->line($ar
                ? 'وصلنا طلب لإعادة تعيين كلمة مرور حسابك.'
                : 'We received a request to reset your account password.')
            ->action($ar ? 'إعادة تعيين كلمة المرور' : 'Reset password', $this->url)
            ->line($ar
                ? 'إذا لم تطلب ذلك، فلا تتخذ أي إجراء.'
                : 'If you did not request this, no action is required.');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CompetitionAppeal extends Model
{
    protected $fillable = [
        'competitive_match_id',
        'tournament_id',
        'user_id',
        'category',
        'reason',
        'evidence',
        'status',
        'resolved_by',
        'decision_note',
        'submitted_at',
        'resolved_at',
    ];

    protected $casts = [
        'evidence' => 'array',
        'submitted_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    public function match()
    {
        return $this->belongsTo(CompetitiveMatch::class, 'competitive_match_id');
    }

    public function tournament()
    {
        return $this->belongsTo(Tournament::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function resolver()
    {
        return $this->belongsTo(User::class, 'resolved_by');
    }
}

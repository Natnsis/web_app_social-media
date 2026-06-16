"use client"

import { useState } from "react"
import Link from "next/link"
import { ChevronLeft, ChevronRight, Bank, Heart, BullseyeArrow, Bell, User, Users, Shield } from "nasicon-react/outline"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"

const stats = [
    {
        label: "Subscribers",
        value: "12k",
        sub: "+8% this week",
        subColor: "text-green-500",
        bg: "bg-blue-50 dark:bg-blue-950",
        iconBg: "bg-blue-100 dark:bg-blue-900",
        Icon: User,
        iconColor: "text-blue-500",
    },
    {
        label: "Campaigns",
        value: "42",
        sub: "Active Global Projects",
        subColor: "text-muted-foreground",
        bg: "bg-orange-50 dark:bg-orange-950",
        iconBg: "bg-orange-100 dark:bg-orange-900",
        Icon: Heart,
        iconColor: "text-orange-500",
    },
    {
        label: "Live Viewers",
        value: "489",
        sub: "● Ongoing Service",
        subColor: "text-red-500",
        bg: "bg-pink-50 dark:bg-pink-950",
        iconBg: "bg-pink-100 dark:bg-pink-900",
        Icon: BullseyeArrow,
        iconColor: "text-pink-500",
    },
]

const financialItems = [
    { label: "Bank & Payout", sub: "Linked: CBE ****3421", Icon: Bank },
    { label: "Donation Reports", sub: "Generate Q3 tax receipts", Icon: Shield },
    { label: "Manage Admins", sub: "12 roles assigned", Icon: Users },
]

export default function AccountSettingsPage() {
    const [notifications, setNotifications] = useState(true)
    const [privateProfile, setPrivateProfile] = useState(false)
    const [twoFactor, setTwoFactor] = useState(false)

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
            <header className="flex shrink-0 items-center gap-2 px-4 py-3">
                <Link href="/account" className="text-primary">
                    <ChevronLeft size={22} />
                </Link>
                <h1 className="text-lg font-bold text-primary">Accounts Settings</h1>
            </header>

            <div className="flex-1 overflow-y-auto px-4 pb-8 space-y-6">
                {/* Stats */}
                <div className="space-y-3">
                    {stats.map((s) => (
                        <div key={s.label} className={`flex items-center gap-4 rounded-2xl p-4 ${s.bg}`}>
                            <div className={`flex size-12 items-center justify-center rounded-full ${s.iconBg}`}>
                                <s.Icon size={22} className={s.iconColor} />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">{s.label}</p>
                                <p className="text-2xl font-bold">{s.value}</p>
                                <p className={`text-xs font-medium ${s.subColor}`}>{s.sub}</p>
                            </div>
                        </div>
                    ))}
                </div>

                <Separator />

                {/* Financial */}
                <div>
                    <h2 className="mb-3 text-base font-bold">Financial &amp; Administration</h2>
                    <div className="space-y-2">
                        {financialItems.map((item) => (
                            <button key={item.label}
                                className="flex w-full items-center gap-3 rounded-2xl border border-border bg-card p-4">
                                <div className="flex size-10 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
                                    <item.Icon size={18} className="text-primary" />
                                </div>
                                <div className="flex-1 text-left">
                                    <p className="text-sm font-semibold">{item.label}</p>
                                    <p className="text-xs text-muted-foreground">{item.sub}</p>
                                </div>
                                <ChevronRight size={16} className="text-muted-foreground" />
                            </button>
                        ))}
                    </div>
                </div>

                <Separator />

                {/* Personal Preferences */}
                <div>
                    <h2 className="mb-3 text-base font-bold">Personal Preferences</h2>
                    <div className="space-y-2">
                        {[
                            { label: "Notifications", sub: "Push & email alerts", Icon: Bell, state: notifications, set: setNotifications },
                            { label: "Private Profile", sub: "Only followers see your posts", Icon: Shield, state: privateProfile, set: setPrivateProfile },
                            { label: "Two-Factor Auth", sub: "Extra login security", Icon: Shield, state: twoFactor, set: setTwoFactor },
                        ].map((item) => (
                            <div key={item.label}
                                className="flex items-center gap-3 rounded-2xl border border-border bg-card p-4">
                                <div className="flex size-10 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
                                    <item.Icon size={18} className="text-primary" />
                                </div>
                                <div className="flex-1">
                                    <p className="text-sm font-semibold">{item.label}</p>
                                    <p className="text-xs text-muted-foreground">{item.sub}</p>
                                </div>
                                <Switch checked={item.state} onCheckedChange={item.set} />
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    )
}

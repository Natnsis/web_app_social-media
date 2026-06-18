"use client"

import { useState } from "react"
import Link from "next/link"
import { ChevronLeft, ChevronRight, Bank, Heart, BullseyeArrow, Bell, User, Users, Shield, Gear, Globe } from "nasicon-react/outline"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"
import { useAuthStore } from "@/lib/store/auth"

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
    const { user } = useAuthStore()
    const [notifications, setNotifications] = useState(true)
    const [privateProfile, setPrivateProfile] = useState(false)
    const [twoFactor, setTwoFactor] = useState(false)
    const preferenceItems = [
        { label: "Notifications", sub: "Push and email alerts for lives, messages, payouts, and moderation.", Icon: Bell, state: notifications, set: setNotifications },
        { label: "Private Profile", sub: "Only approved followers can see personal posts and saved activity.", Icon: Shield, state: privateProfile, set: setPrivateProfile },
        { label: "Two-Factor Auth", sub: "Require a second step before signing in to owner tools.", Icon: Shield, state: twoFactor, set: setTwoFactor },
    ]

    return (
        <div className="flex h-full flex-col overflow-hidden bg-background">
            <div className="hidden h-full overflow-hidden p-4 lg:grid lg:grid-cols-[260px_minmax(0,1fr)_300px] lg:gap-4">
                <aside className="flex min-h-0 flex-col rounded-2xl border border-border bg-card">
                    <div className="border-b border-border p-4">
                        <Link href="/account" className="mb-4 inline-flex items-center gap-2 text-xs font-semibold text-primary">
                            <ChevronLeft size={16} />
                            Back to profile
                        </Link>
                        <div className="flex items-center gap-3">
                            <Avatar className="size-11">
                                <AvatarFallback className="bg-primary text-primary-foreground text-sm font-bold">{user?.initials ?? "AT"}</AvatarFallback>
                            </Avatar>
                            <div className="min-w-0">
                                <p className="truncate text-sm font-black">{user?.org ?? "Beza International"}</p>
                                <p className="truncate text-xs text-muted-foreground">{user?.role ?? "Global Administrator"}</p>
                            </div>
                        </div>
                    </div>

                    <nav className="flex-1 space-y-5 overflow-y-auto p-3">
                        {[
                            { title: "Account", items: [{ label: "Profile", Icon: User }, { label: "Notifications", Icon: Bell }, { label: "Privacy", Icon: Shield }] },
                            { title: "Owner Tools", items: [{ label: "Payouts", Icon: Bank }, { label: "Admins", Icon: Users }, { label: "Reports", Icon: BullseyeArrow }] },
                        ].map((section) => (
                            <div key={section.title}>
                                <p className="mb-2 px-3 text-[10px] font-black uppercase tracking-[0.18em] text-muted-foreground">{section.title}</p>
                                <div className="space-y-1">
                                    {section.items.map(({ label, Icon }, index) => (
                                        <button
                                            key={label}
                                            className={`flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition-colors ${index === 0 && section.title === "Account" ? "bg-primary/10 text-primary" : "text-muted-foreground hover:bg-muted hover:text-foreground"}`}
                                        >
                                            <Icon size={17} />
                                            {label}
                                        </button>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </nav>
                </aside>

                <main className="min-w-0 overflow-y-auto rounded-2xl border border-border bg-card">
                    <div className="border-b border-border px-5 py-4">
                        <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Settings</p>
                        <h1 className="mt-1 text-2xl font-black tracking-tight">Account Settings</h1>
                        <p className="mt-1 text-sm text-muted-foreground">Manage profile access, church owner tools, payouts, and security preferences.</p>
                    </div>

                    <div className="space-y-5 p-5">
                        <section>
                            <div className="mb-3 flex items-center justify-between">
                                <div>
                                    <h2 className="text-base font-black">Ministry Snapshot</h2>
                                    <p className="text-xs text-muted-foreground">High-level performance for the owner workspace.</p>
                                </div>
                                <Badge variant="outline" className="rounded-lg">Live data</Badge>
                            </div>
                            <div className="grid grid-cols-3 gap-3">
                                {stats.map((s) => (
                                    <div key={s.label} className="rounded-xl border border-border bg-background p-4">
                                        <div className="mb-4 flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                            <s.Icon size={20} />
                                        </div>
                                        <p className="text-xs text-muted-foreground">{s.label}</p>
                                        <p className="mt-1 text-2xl font-black">{s.value}</p>
                                        <p className="mt-1 text-xs font-medium text-muted-foreground">{s.sub}</p>
                                    </div>
                                ))}
                            </div>
                        </section>

                        <section className="rounded-xl border border-border bg-background">
                            <div className="border-b border-border px-4 py-3">
                                <h2 className="text-sm font-black">Financial & Administration</h2>
                                <p className="mt-1 text-xs text-muted-foreground">Payouts, reports, and team access controls.</p>
                            </div>
                            <div className="divide-y divide-border">
                                {financialItems.map((item) => (
                                    <button key={item.label} className="flex w-full items-center gap-3 px-4 py-3 text-left transition-colors hover:bg-muted/45">
                                        <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                            <item.Icon size={18} />
                                        </div>
                                        <div className="min-w-0 flex-1">
                                            <p className="text-sm font-semibold">{item.label}</p>
                                            <p className="truncate text-xs text-muted-foreground">{item.sub}</p>
                                        </div>
                                        <ChevronRight size={16} className="text-muted-foreground" />
                                    </button>
                                ))}
                            </div>
                        </section>

                        <section className="rounded-xl border border-border bg-background">
                            <div className="border-b border-border px-4 py-3">
                                <h2 className="text-sm font-black">Personal Preferences</h2>
                                <p className="mt-1 text-xs text-muted-foreground">Privacy, alerts, and sign-in protection.</p>
                            </div>
                            <div className="divide-y divide-border">
                                {preferenceItems.map((item) => (
                                    <div key={item.label} className="flex items-center gap-3 px-4 py-3">
                                        <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                                            <item.Icon size={18} />
                                        </div>
                                        <div className="min-w-0 flex-1">
                                            <p className="text-sm font-semibold">{item.label}</p>
                                            <p className="text-xs text-muted-foreground">{item.sub}</p>
                                        </div>
                                        <Switch checked={item.state} onCheckedChange={item.set} />
                                    </div>
                                ))}
                            </div>
                        </section>
                    </div>
                </main>

                <aside className="flex min-h-0 flex-col gap-4">
                    <section className="rounded-2xl border border-border bg-card p-4">
                        <div className="flex items-center justify-between">
                            <h2 className="text-sm font-black">Security Status</h2>
                            <Shield size={18} className="text-primary" />
                        </div>
                        <div className="mt-4 space-y-3">
                            {[
                                ["Owner role", "Verified"],
                                ["Two-factor", twoFactor ? "Enabled" : "Off"],
                                ["Profile visibility", privateProfile ? "Private" : "Public"],
                            ].map(([label, value]) => (
                                <div key={label} className="flex items-center justify-between rounded-xl bg-muted/50 px-3 py-2">
                                    <span className="text-xs text-muted-foreground">{label}</span>
                                    <span className="text-xs font-bold">{value}</span>
                                </div>
                            ))}
                        </div>
                        <Button className="mt-4 w-full rounded-xl">Review Access</Button>
                    </section>

                    <section className="rounded-2xl border border-border bg-card p-4">
                        <div className="flex items-center gap-3">
                            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                <Globe size={18} />
                            </div>
                            <div>
                                <p className="text-sm font-black">Global Ministry Hub</p>
                                <p className="text-xs text-muted-foreground">Public discovery profile</p>
                            </div>
                        </div>
                        <div className="mt-4 rounded-xl border border-border bg-background p-3">
                            <p className="text-xs text-muted-foreground">Profile URL</p>
                            <p className="mt-1 truncate text-sm font-semibold">faithconnect.app/beza</p>
                        </div>
                    </section>

                    <section className="rounded-2xl border border-border bg-primary p-4 text-primary-foreground">
                        <Gear size={18} />
                        <p className="mt-4 text-sm font-black">Owner settings are active</p>
                        <p className="mt-1 text-xs text-primary-foreground/70">Changes here affect payouts, moderation, and public ministry visibility.</p>
                    </section>
                </aside>
            </div>

            <div className="flex h-full flex-col overflow-hidden lg:hidden">
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
        </div>
    )
}

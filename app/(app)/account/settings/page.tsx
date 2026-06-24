"use client"

import { useState, useEffect, useRef } from "react"
import Link from "next/link"
import { ChevronLeft, ChevronRight, Camera, Loader2 } from "lucide-react"
import { Bank, Heart, BullseyeArrow, Bell, User, Users, Shield } from "nasicon-react/outline"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"
import { useAuthStore } from "@/lib/store/auth"
import { useProfile, useUpdateProfile } from "@/hooks/use-profile"
import { updateProfileSchema } from "@/lib/validation/user"

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

    const [fullName, setFullName] = useState("")
    const [bio, setBio] = useState("")
    const [email, setEmail] = useState("")
    const [phoneNumber, setPhoneNumber] = useState("")
    const [avatarFile, setAvatarFile] = useState<File | null>(null)
    const [avatarPreview, setAvatarPreview] = useState<string | null>(null)
    const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({})
    const [successMsg, setSuccessMsg] = useState("")
    const avatarInputRef = useRef<HTMLInputElement>(null)

    const { data: profileData, isLoading: profileLoading } = useProfile()
    const updateProfileMutation = useUpdateProfile()

    useEffect(() => {
        if (profileData?.data) {
            setFullName(profileData.data.fullName || "")
            setBio(profileData.data.bio || "")
            setEmail(profileData.data.email || "")
            setPhoneNumber(profileData.data.phoneNumber || "")
        }
    }, [profileData])

    const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (file) {
            setAvatarFile(file)
            setAvatarPreview(URL.createObjectURL(file))
        }
    }

    const handleProfileSubmit = (e: React.FormEvent) => {
        e.preventDefault()
        setFieldErrors({})
        setSuccessMsg("")

        const validated = updateProfileSchema.safeParse({
            fullName: fullName.trim(),
            bio: bio.trim() || undefined,
            email: email.trim(),
            phoneNumber: phoneNumber.trim() || undefined,
        })

        if (!validated.success) {
            const errors: Record<string, string> = {}
            validated.error.issues.forEach((issue) => {
                if (issue.path[0]) errors[issue.path[0].toString()] = issue.message
            })
            setFieldErrors(errors)
            return
        }

        const formData = new FormData()
        formData.append("fullName", validated.data.fullName)
        formData.append("email", validated.data.email)
        if (validated.data.bio) formData.append("bio", validated.data.bio)
        if (validated.data.phoneNumber) formData.append("phoneNumber", validated.data.phoneNumber)
        if (avatarFile) formData.append("avatar", avatarFile)

        updateProfileMutation.mutate(formData, {
            onSuccess: () => {
                setSuccessMsg("Profile updated successfully")
                setAvatarFile(null)
                setAvatarPreview(null)
            },
            onError: (err: any) => {
                setFieldErrors({ form: err.message || "Failed to update profile" })
            },
        })
    }

    const preferenceItems = [
        { label: "Notifications", sub: "Push and email alerts for lives, messages, payouts, and moderation.", Icon: Bell, state: notifications, set: setNotifications },
        { label: "Private Profile", sub: "Only approved followers can see personal posts and saved activity.", Icon: Shield, state: privateProfile, set: setPrivateProfile },
        { label: "Two-Factor Auth", sub: "Require a second step before signing in to owner tools.", Icon: Shield, state: twoFactor, set: setTwoFactor },
    ]

    return (
        <div className="flex h-full w-full flex-col overflow-hidden bg-background">
            {/* Mobile header */}
            <header className="flex shrink-0 items-center gap-2 px-4 py-3 lg:hidden">
                <Link href="/account" className="text-primary">
                    <ChevronLeft size={22} />
                </Link>
                <h1 className="text-lg font-bold text-primary">Account Settings</h1>
            </header>

            {/* Desktop layout */}
            <div className="hidden h-full overflow-y-auto lg:block">
                <div className="mx-auto max-w-5xl px-8 py-8">
                    <div className="mb-8">
                        <h1 className="text-3xl font-black tracking-tight">Account Settings</h1>
                        <p className="mt-1 text-sm text-muted-foreground">Manage your profile, preferences, and account details</p>
                    </div>
                    <div className="grid grid-cols-[1fr_360px] gap-8">
                        <div className="space-y-6">

                            {/* Edit Profile */}
                            <section className="rounded-2xl border border-border bg-card p-6">
                                <h2 className="text-lg font-black">Edit Profile</h2>
                                <p className="mt-1 text-sm text-muted-foreground">Update your personal information and photo.</p>

                                <form onSubmit={handleProfileSubmit} className="mt-6 space-y-5">
                                    <div className="flex items-center gap-5">
                                        <div className="relative">
                                            <Avatar className="size-20 cursor-pointer" onClick={() => avatarInputRef.current?.click()}>
                                                {avatarPreview ? (
                                                    <AvatarImage src={avatarPreview} />
                                                ) : profileData?.data?.avatarUrl ? (
                                                    <AvatarImage src={profileData.data.avatarUrl} />
                                                ) : (
                                                    <AvatarFallback className="bg-primary/20 text-primary text-2xl font-bold">
                                                        {user?.initials ?? "AT"}
                                                    </AvatarFallback>
                                                )}
                                            </Avatar>
                                            <button type="button" onClick={() => avatarInputRef.current?.click()} className="absolute -bottom-0.5 -right-0.5 flex size-7 items-center justify-center rounded-full bg-primary text-primary-foreground ring-2 ring-background">
                                                <Camera size={14} />
                                            </button>
                                            <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarChange} />
                                        </div>
                                        <div className="text-sm text-muted-foreground">
                                            <p className="font-medium text-foreground">Profile photo</p>
                                            <p>PNG, JPG up to 5MB</p>
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-2 gap-4">
                                        <div>
                                            <label className="mb-1.5 block text-sm font-semibold text-foreground">Full Name</label>
                                            <Input value={fullName} onChange={(e) => setFullName(e.target.value)} placeholder="Your full name" />
                                            {fieldErrors.fullName && <p className="mt-1 text-xs text-destructive">{fieldErrors.fullName}</p>}
                                        </div>
                                        <div>
                                            <label className="mb-1.5 block text-sm font-semibold text-foreground">Email</label>
                                            <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="your@email.com" />
                                            {fieldErrors.email && <p className="mt-1 text-xs text-destructive">{fieldErrors.email}</p>}
                                        </div>
                                    </div>

                                    <div>
                                        <label className="mb-1.5 block text-sm font-semibold text-foreground">Phone Number</label>
                                        <Input type="tel" value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} placeholder="+251912345678" />
                                        {fieldErrors.phoneNumber && <p className="mt-1 text-xs text-destructive">{fieldErrors.phoneNumber}</p>}
                                    </div>

                                    <div>
                                        <label className="mb-1.5 block text-sm font-semibold text-foreground">Bio</label>
                                        <Textarea value={bio} onChange={(e) => setBio(e.target.value)} placeholder="Tell us about yourself..." rows={3} />
                                        {fieldErrors.bio && <p className="mt-1 text-xs text-destructive">{fieldErrors.bio}</p>}
                                    </div>

                                    {fieldErrors.form && (
                                        <div className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{fieldErrors.form}</div>
                                    )}

                                    {successMsg && (
                                        <div className="rounded-xl bg-green-50 p-3 text-sm text-green-700 dark:bg-green-950 dark:text-green-400">{successMsg}</div>
                                    )}

                                    <Button type="submit" disabled={updateProfileMutation.isPending} className="rounded-xl">
                                        {updateProfileMutation.isPending ? (
                                            <><Loader2 size={16} className="animate-spin" /> Saving...</>
                                        ) : (
                                            "Save Changes"
                                        )}
                                    </Button>
                                </form>
                            </section>

                            {/* Personal Preferences */}
                            <section className="rounded-2xl border border-border bg-card p-6">
                                <h2 className="text-lg font-black">Personal Preferences</h2>
                                <p className="mt-1 text-sm text-muted-foreground">Manage your notification and privacy settings.</p>
                                <div className="mt-6 space-y-2">
                                    {[
                                        { label: "Notifications", sub: "Push & email alerts", Icon: Bell, state: notifications, set: setNotifications },
                                        { label: "Private Profile", sub: "Only followers see your posts", Icon: Shield, state: privateProfile, set: setPrivateProfile },
                                        { label: "Two-Factor Auth", sub: "Extra login security", Icon: Shield, state: twoFactor, set: setTwoFactor },
                                    ].map((item) => (
                                        <div key={item.label}
                                            className="flex items-center gap-3 rounded-xl border border-border bg-background p-4">
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
                            </section>

                            {/* Financial */}
                            <section className="rounded-2xl border border-border bg-card p-6">
                                <h2 className="text-lg font-black">Financial &amp; Administration</h2>
                                <p className="mt-1 text-sm text-muted-foreground">Manage payouts, reports, and team roles.</p>
                                <div className="mt-6 space-y-2">
                                    {financialItems.map((item) => (
                                        <button key={item.label}
                                            className="flex w-full items-center gap-3 rounded-xl border border-border bg-background p-4 hover:bg-muted/50 transition-colors">
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
                            </section>

                        </div>

                        {/* Desktop Right Panel — Stats */}
                        <aside className="space-y-4">
                            {stats.map((s) => (
                                <div key={s.label} className={`flex items-center gap-4 rounded-2xl p-5 ${s.bg}`}>
                                    <div className={`flex size-12 shrink-0 items-center justify-center rounded-full ${s.iconBg}`}>
                                        <s.Icon size={22} className={s.iconColor} />
                                    </div>
                                    <div>
                                        <p className="text-sm text-muted-foreground">{s.label}</p>
                                        <p className="text-2xl font-bold">{s.value}</p>
                                        <p className={`text-xs font-medium ${s.subColor}`}>{s.sub}</p>
                                    </div>
                                </div>
                            ))}
                        </aside>
                    </div>
                </div>
            </div>

            {/* Mobile layout */}
            <div className="flex-1 overflow-y-auto px-4 pb-8 space-y-6 lg:hidden">
                {/* Edit Profile */}
                <section className="rounded-2xl border border-border bg-card p-4">
                    <h2 className="text-sm font-black">Edit Profile</h2>
                    <p className="mt-1 text-xs text-muted-foreground">Update your personal information and photo.</p>

                    <form onSubmit={handleProfileSubmit} className="mt-4 space-y-4">
                        <div className="flex items-center gap-4">
                            <div className="relative">
                                <Avatar className="size-16 cursor-pointer" onClick={() => avatarInputRef.current?.click()}>
                                    {avatarPreview ? (
                                        <AvatarImage src={avatarPreview} />
                                    ) : profileData?.data?.avatarUrl ? (
                                        <AvatarImage src={profileData.data.avatarUrl} />
                                    ) : (
                                        <AvatarFallback className="bg-primary/20 text-primary text-base font-bold">
                                            {user?.initials ?? "AT"}
                                        </AvatarFallback>
                                    )}
                                </Avatar>
                                <button type="button" onClick={() => avatarInputRef.current?.click()} className="absolute -bottom-0.5 -right-0.5 flex size-6 items-center justify-center rounded-full bg-primary text-primary-foreground ring-2 ring-background">
                                    <Camera size={12} />
                                </button>
                                <input ref={avatarInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarChange} />
                            </div>
                            <div className="text-xs text-muted-foreground">
                                <p className="font-medium">Profile photo</p>
                                <p>PNG, JPG up to 5MB</p>
                            </div>
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-semibold text-foreground">Full Name</label>
                            <Input value={fullName} onChange={(e) => setFullName(e.target.value)} placeholder="Your full name" />
                            {fieldErrors.fullName && <p className="mt-1 text-xs text-destructive">{fieldErrors.fullName}</p>}
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-semibold text-foreground">Email</label>
                            <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="your@email.com" />
                            {fieldErrors.email && <p className="mt-1 text-xs text-destructive">{fieldErrors.email}</p>}
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-semibold text-foreground">Phone Number</label>
                            <Input type="tel" value={phoneNumber} onChange={(e) => setPhoneNumber(e.target.value)} placeholder="+251912345678" />
                            {fieldErrors.phoneNumber && <p className="mt-1 text-xs text-destructive">{fieldErrors.phoneNumber}</p>}
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-semibold text-foreground">Bio</label>
                            <Textarea value={bio} onChange={(e) => setBio(e.target.value)} placeholder="Tell us about yourself..." rows={3} />
                            {fieldErrors.bio && <p className="mt-1 text-xs text-destructive">{fieldErrors.bio}</p>}
                        </div>

                        {fieldErrors.form && (
                            <div className="rounded-xl bg-destructive/10 p-3 text-xs text-destructive">{fieldErrors.form}</div>
                        )}

                        {successMsg && (
                            <div className="rounded-xl bg-green-50 p-3 text-xs text-green-700 dark:bg-green-950 dark:text-green-400">{successMsg}</div>
                        )}

                        <Button type="submit" disabled={updateProfileMutation.isPending} className="w-full rounded-xl">
                            {updateProfileMutation.isPending ? (
                                <><Loader2 size={16} className="animate-spin" /> Saving...</>
                            ) : (
                                "Save Changes"
                            )}
                        </Button>
                    </form>
                </section>

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

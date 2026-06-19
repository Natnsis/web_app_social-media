"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { useAuthStore } from "@/lib/store/auth"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { ThemeToggle } from "@/components/theme-toggle"
import {
    Dialog, DialogTrigger, DialogContent, DialogHeader,
    DialogTitle, DialogDescription, DialogFooter, DialogClose,
} from "@/components/ui/dialog"
import {
    Heart, Users, Globe, Gift, CalendarAlt,
    Xmark, ArrowRightFromBracket, HouseChimneyBlank,
    Church, ChevronRight,
} from "nasicon-react/outline"
import { GridCircle, Bell } from "nasicon-react/solid"
import Image from "next/image"
import { BarChart3, Sparkles, Loader } from "lucide-react"
import { useCampaigns, useCreateCampaign } from "@/hooks/use-campaigns"
import type { Campaign } from "@/lib/api/campaigns"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select"

const categoryGradients: Record<string, string> = {
    Building: "from-blue-600 to-blue-400",
    Missions: "from-emerald-600 to-emerald-400",
    Community: "from-amber-600 to-amber-400",
    Relief: "from-red-600 to-red-400",
    Creative: "from-purple-600 to-purple-400",
    default: "from-primary to-primary/60",
}

const topDonors = [
    { name: "Michael T.", initials: "MT", amount: 2500, badge: "Gold Donor" },
    { name: "Sarah K.", initials: "SK", amount: 1800, badge: "Gold Donor" },
    { name: "Pastor David", initials: "PD", amount: 1200, badge: "Silver Donor" },
    { name: "Hannah W.", initials: "HW", amount: 900, badge: "Silver Donor" },
    { name: "Daniel M.", initials: "DM", amount: 750, badge: "Bronze Donor" },
]

const categories = [
    { label: "All Campaigns", active: true },
    { label: "Building", active: false },
    { label: "Missions", active: false },
    { label: "Community", active: false },
    { label: "Relief", active: false },
    { label: "Creative", active: false },
]

function daysLeft(dateStr: string) {
    const diff = new Date(dateStr).getTime() - Date.now()
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)))
}

function getGradient(category?: string) {
    return categoryGradients[category ?? ""] || categoryGradients.default
}

/* ── Create Campaign Dialog ── */

function CreateCampaignDialog() {
    const [open, setOpen] = useState(false)
    const [title, setTitle] = useState("")
    const [description, setDescription] = useState("")
    const [goalAmount, setGoalAmount] = useState("")
    const [startAt, setStartAt] = useState("")
    const [endAt, setEndAt] = useState("")
    const [status, setStatus] = useState<string>("DRAFT")
    const [image, setImage] = useState<File | null>(null)
    const createCampaign = useCreateCampaign()

    const handleSubmit = async () => {
        if (!title || !description || !goalAmount || !startAt || !endAt) return
        try {
            await createCampaign.mutateAsync({
                title,
                description,
                goalAmount: Number(goalAmount),
                startAt: new Date(startAt).toISOString(),
                endAt: new Date(endAt).toISOString(),
                isActive: status === "ACTIVE",
                status: status as Campaign["status"],
                image,
            })
            setOpen(false)
            setTitle("")
            setDescription("")
            setGoalAmount("")
            setStartAt("")
            setEndAt("")
            setStatus("DRAFT")
            setImage(null)
        } catch { }
    }

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger render={<Button className="rounded-xl gap-1.5"><Heart size={15} />Start a Campaign</Button>} />
            <DialogContent className="sm:max-w-lg">
                <DialogHeader>
                    <DialogTitle className="text-lg">Start a Campaign</DialogTitle>
                    <DialogDescription>Launch a fundraising campaign for your church or ministry.</DialogDescription>
                </DialogHeader>

                <div className="space-y-4">
                    <div>
                        <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Title</label>
                        <Input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Campaign title" />
                    </div>
                    <div>
                        <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Description</label>
                        <Textarea value={description} onChange={(e) => setDescription(e.target.value)} placeholder="Describe your campaign" rows={3} />
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Goal Amount ($)</label>
                            <Input type="number" value={goalAmount} onChange={(e) => setGoalAmount(e.target.value)} placeholder="50000" />
                        </div>
                        <div>
                            <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Status</label>
                            <Select value={status} onValueChange={(v) => v && setStatus(v)}>
                                <SelectTrigger><SelectValue /></SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="DRAFT">Draft</SelectItem>
                                    <SelectItem value="ACTIVE">Active</SelectItem>
                                    <SelectItem value="PAUSED">Paused</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Start Date</label>
                            <Input type="date" value={startAt} onChange={(e) => setStartAt(e.target.value)} />
                        </div>
                        <div>
                            <label className="text-xs font-medium text-muted-foreground mb-1.5 block">End Date</label>
                            <Input type="date" value={endAt} onChange={(e) => setEndAt(e.target.value)} />
                        </div>
                    </div>
                    <div>
                        <label className="text-xs font-medium text-muted-foreground mb-1.5 block">Cover Image</label>
                        <Input type="file" accept="image/*" onChange={(e) => setImage(e.target.files?.[0] ?? null)} />
                    </div>
                </div>

                <DialogFooter>
                    <DialogClose render={<Button variant="outline" className="rounded-xl">Cancel</Button>} />
                    <Button className="rounded-xl gap-1.5" onClick={handleSubmit} disabled={createCampaign.isPending || !title || !description || !goalAmount || !startAt || !endAt}>
                        {createCampaign.isPending ? <Loader size={14} className="animate-spin" /> : <Heart size={14} />}
                        {createCampaign.isPending ? "Creating..." : "Launch Campaign"}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}

/* ── Donate Dialog ── */

function DonateDialog({ campaign }: { campaign: Campaign }) {
    const [amount, setAmount] = useState<number | null>(null)
    const [customAmount, setCustomAmount] = useState("")
    const presetAmounts = [10, 25, 50, 100, 250]

    return (
        <Dialog>
            <DialogTrigger render={<Button size="sm" className="rounded-xl gap-1.5 w-full"><Heart size={14} />Donate</Button>} />
            <DialogContent className="sm:max-w-sm">
                <DialogHeader>
                    <DialogTitle className="text-lg">Support This Campaign</DialogTitle>
                    <DialogDescription>
                        Your gift supports <span className="font-semibold text-foreground">{campaign.title}</span> by {campaign.church.name}.
                    </DialogDescription>
                </DialogHeader>

                <div className="space-y-3">
                    <p className="text-xs font-bold text-muted-foreground uppercase tracking-wider">Select Amount</p>
                    <div className="grid grid-cols-3 gap-2">
                        {presetAmounts.map((a) => (
                            <button
                                key={a}
                                onClick={() => { setAmount(a); setCustomAmount("") }}
                                className={`rounded-xl border px-3 py-2.5 text-sm font-semibold transition-colors ${amount === a
                                    ? "border-primary bg-primary/10 text-primary"
                                    : "border-border hover:border-primary/50 hover:text-foreground"
                                    }`}
                            >
                                ${a}
                            </button>
                        ))}
                    </div>
                    <div className="relative">
                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">$</span>
                        <input
                            placeholder="Custom amount"
                            value={customAmount}
                            onChange={(e) => { setCustomAmount(e.target.value); setAmount(null) }}
                            className="w-full rounded-xl border border-border bg-background py-2.5 pl-7 pr-3 text-sm outline-none focus:border-primary"
                        />
                    </div>
                </div>

                <Separator />

                <div className="space-y-2">
                    <p className="text-xs font-bold text-muted-foreground uppercase tracking-wider">Summary</p>
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">Donation</span>
                        <span className="font-semibold">${amount ? amount : customAmount || "0"}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                        <span className="text-muted-foreground">Processing Fee</span>
                        <span className="font-semibold">$0.00</span>
                    </div>
                    <Separator />
                    <div className="flex justify-between text-sm font-bold">
                        <span>Total</span>
                        <span>${amount ? amount : customAmount || "0"}</span>
                    </div>
                </div>

                <DialogFooter>
                    <DialogClose render={<Button variant="outline" className="rounded-xl">Cancel</Button>} />
                    <Button className="rounded-xl gap-1.5" disabled={!amount && !customAmount}>
                        <Heart size={14} />
                        Complete Gift
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    )
}

/* ── Campaign Card ── */

function CampaignCard({ campaign }: { campaign: Campaign }) {
    const progress = Math.min(Math.round((campaign.currentBalance / campaign.goalAmount) * 100), 100)
    const remaining = daysLeft(campaign.endsAt)

    return (
        <div className="group overflow-hidden rounded-2xl border border-border bg-card transition-shadow hover:shadow-lg">
            <div className={`relative h-36 bg-gradient-to-br ${getGradient(campaign.status)}`}>
                {campaign.coverImageUrl && (
                    <Image src={campaign.coverImageUrl} alt={campaign.title} fill className="object-cover" />
                )}
                <div className="absolute inset-0 bg-black/10" />
                <div className="absolute bottom-3 left-3">
                    <Badge className="bg-white/20 text-white border-0 backdrop-blur-sm text-[10px]">
                        {campaign.status}
                    </Badge>
                </div>
                <div className="absolute top-3 right-3">
                    <Heart size={16} className="text-white/70 hover:text-white transition-colors cursor-pointer" />
                </div>
            </div>
            <div className="p-4 space-y-3">
                <div>
                    <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground mb-1">
                        <Users size={12} />
                        <span>{campaign.church.name}</span>
                    </div>
                    <h3 className="font-bold text-sm leading-snug">{campaign.title}</h3>
                    <p className="text-xs text-muted-foreground mt-1.5 line-clamp-2">{campaign.description}</p>
                </div>

                <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-xs">
                        <span className="font-semibold">${campaign.currentBalance.toLocaleString()}</span>
                        <span className="text-muted-foreground">of ${campaign.goalAmount.toLocaleString()}</span>
                    </div>
                    <div className="h-2 rounded-full bg-muted overflow-hidden">
                        <div
                            className="h-full rounded-full bg-primary transition-all duration-500"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                    <div className="flex items-center justify-between text-[11px]">
                        <span className="text-muted-foreground">{campaign.donorCount} donors</span>
                        <span className="flex items-center gap-1 font-semibold text-amber-600">
                            <CalendarAlt size={11} />
                            {remaining} days left
                        </span>
                    </div>
                </div>

                <DonateDialog campaign={campaign} />
            </div>
        </div>
    )
}

/* ── Right Panel ── */

function CampaignsRightPanel({ campaigns }: { campaigns: Campaign[] }) {
    const totalRaised = campaigns.reduce((sum, c) => sum + c.currentBalance, 0)
    const totalDonors = campaigns.reduce((sum, c) => sum + c.donorCount, 0)

    return (
        <aside className="hidden h-full shrink-0 flex-col overflow-y-auto rounded-2xl border border-border bg-card p-4 xl:flex">
            <div className="rounded-xl bg-gradient-to-br from-primary to-primary/80 p-4 text-primary-foreground">
                <p className="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-primary-foreground/70">
                    <Sparkles size={13} />
                    Your Impact
                </p>
                <div className="mt-4 space-y-3">
                    <div>
                        <p className="text-2xl font-black">${totalRaised.toLocaleString()}</p>
                        <p className="text-[11px] text-primary-foreground/70">total raised across all campaigns</p>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <p className="text-lg font-black">{totalDonors}</p>
                            <p className="text-[11px] text-primary-foreground/70">total donors</p>
                        </div>
                        <div>
                            <p className="text-lg font-black">{campaigns.length}</p>
                            <p className="text-[11px] text-primary-foreground/70">active campaigns</p>
                        </div>
                    </div>
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <BarChart3 size={14} className="text-primary" />
                    Categories
                </p>
                <div className="space-y-1">
                    {categories.map((cat) => (
                        <button
                            key={cat.label}
                            className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs transition-colors ${cat.active
                                ? "bg-primary/10 font-semibold text-primary"
                                : "text-muted-foreground hover:bg-muted hover:text-foreground"
                                }`}
                        >
                            <span>{cat.label}</span>
                        </button>
                    ))}
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <Gift size={14} className="text-primary" />
                    Top Donors
                </p>
                <div className="space-y-2">
                    {topDonors.map((donor) => (
                        <div key={donor.name} className="flex items-center gap-2.5 rounded-xl border border-border bg-background p-2.5">
                            <Avatar className="size-8">
                                <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                    {donor.initials}
                                </AvatarFallback>
                            </Avatar>
                            <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-1.5">
                                    <p className="text-xs font-semibold truncate">{donor.name}</p>
                                    <Badge variant="outline" className="text-[8px] px-1 py-0 h-4 border-primary/30 text-primary">
                                        {donor.badge}
                                    </Badge>
                                </div>
                                <p className="text-[11px] text-muted-foreground">${donor.amount.toLocaleString()} donated</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <Globe size={14} className="text-primary" />
                    Global Reach
                </p>
                <div className="rounded-xl border border-border bg-background p-4 space-y-2">
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Countries Served</span>
                        <span className="font-semibold text-primary">8</span>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Active Missions</span>
                        <span className="font-semibold">12</span>
                    </div>
                    <p className="text-[10px] text-muted-foreground leading-relaxed">
                        Your generosity funds mission outposts across Eastern Africa and Southern Asia.
                    </p>
                </div>
            </div>
        </aside>
    )
}

/* ── Mobile Side Drawer ── */

function MobileSideDrawer({ open, onClose }: { open: boolean; onClose: () => void }) {
    const { user, logout } = useAuthStore()
    const router = useRouter()

    return (
        <>
            {open && <div className="fixed inset-0 z-40 bg-black/40" onClick={onClose} />}
            <div className={`fixed inset-y-0 left-0 z-50 flex w-72 flex-col bg-background shadow-xl transition-transform duration-300 ${open ? "translate-x-0" : "-translate-x-full"}`}>
                <div className="flex items-center justify-end px-4 pt-4">
                    <Button variant="ghost" size="icon-sm" onClick={onClose}><Xmark size={20} /></Button>
                </div>
                <div className="flex items-center gap-3 px-5 py-3">
                    <Avatar size="lg">
                        <AvatarFallback className="bg-primary text-primary-foreground text-base">{user?.initials ?? "Y"}</AvatarFallback>
                    </Avatar>
                    <div>
                        <p className="font-semibold">{user?.name ?? "Yared"}</p>
                        <p className="text-xs text-muted-foreground">{user?.role ?? "Church Administrator"}</p>
                    </div>
                </div>
                <div className="mx-4 mb-3 flex items-center gap-2 rounded-xl border border-border px-3 py-2">
                    <Church size={18} className="text-muted-foreground" />
                    <p className="flex-1 text-sm font-medium">{user?.org ?? "Beza International"}</p>
                    <Badge className="text-[10px]">ADMIN</Badge>
                </div>
                <div className="flex-1 overflow-y-auto px-4 pb-4 space-y-4">
                    <div>
                        <p className="mb-1 px-1 text-[10px] font-bold tracking-widest text-muted-foreground">DISCOVER</p>
                        <button onClick={() => { router.push("/"); onClose() }} className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors hover:bg-muted">
                            <span className="text-muted-foreground"><HouseChimneyBlank size={18} /></span>
                            <span className="flex-1 text-left">Home</span>
                        </button>
                    </div>
                    <div>
                        <p className="mb-1 px-1 text-[10px] font-bold tracking-widest text-muted-foreground">COMMUNITY</p>
                        <button onClick={() => { router.push("/chats"); onClose() }} className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors hover:bg-muted">
                            <span className="text-muted-foreground"><Users size={18} /></span>
                            <span className="flex-1 text-left">Groups</span>
                        </button>
                        <button className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm bg-primary/10 font-semibold text-primary">
                            <span className="text-primary"><Heart size={18} /></span>
                            <span className="flex-1 text-left">Campaigns</span>
                        </button>
                    </div>
                    <div>
                        <p className="mb-1 px-1 text-[10px] font-bold tracking-widest text-muted-foreground">PREFERENCES</p>
                        <button className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors hover:bg-muted">
                            <span className="text-muted-foreground"><Globe size={18} /></span>
                            <span className="flex-1 text-left">Language</span>
                            <span className="text-xs text-muted-foreground">English</span>
                            <ChevronRight size={14} className="text-muted-foreground" />
                        </button>
                    </div>
                </div>
                <Separator />
                <div className="px-5 py-4 flex items-center justify-between">
                    <p className="text-[10px] text-muted-foreground">v2.4.0</p>
                    <button onClick={() => { logout(); router.push("/login") }}
                        className="flex items-center gap-2 text-sm font-medium text-destructive">
                        <ArrowRightFromBracket size={18} /> Logout
                    </button>
                </div>
            </div>
        </>
    )
}

/* ── Main Page ── */

export default function CampaignsPage() {
    const [drawerOpen, setDrawerOpen] = useState(false)
    const { data, isLoading, isError } = useCampaigns()
    const campaigns = data?.data ?? []

    return (
        <>
            <MobileSideDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)} />

            <div className="h-full overflow-y-auto bg-background">
                {/* Mobile Common Header */}
                <div className="sticky top-0 z-10 border-b border-border bg-background/80 backdrop-blur-md lg:hidden">
                    <header className="flex items-center justify-between px-3 py-2">
                        <Button variant="ghost" size="icon-sm" onClick={() => setDrawerOpen(true)}>
                            <GridCircle size={26} />
                        </Button>
                        <h1 className="text-lg font-bold tracking-tight">
                            Faith<span className="text-primary">Connect</span>
                        </h1>
                        <div className="flex items-center gap-1">
                            <ThemeToggle />
                            <Button variant="ghost" size="icon-sm"><Bell size={20} /></Button>
                        </div>
                    </header>
                </div>

                {/* Mobile: Start a Campaign */}
                <div className="lg:hidden px-4 pt-3 pb-0">
                    <CreateCampaignDialog />
                </div>

                <div className="mx-auto max-w-[1500px]">
                    {/* Desktop Header */}
                    <div className="hidden lg:flex items-center justify-between px-4 pt-4 pb-2">
                        <div>
                            <h1 className="text-2xl font-black">Campaigns</h1>
                            <p className="text-sm text-muted-foreground">Discover and support faith-driven causes around the world</p>
                        </div>
                        <CreateCampaignDialog />
                    </div>

                    {/* Mobile: categories filter */}
                    <div className="lg:hidden px-4 py-3 overflow-x-auto">
                        <div className="flex gap-2">
                            {categories.map((cat) => (
                                <button
                                    key={cat.label}
                                    className={`shrink-0 rounded-full px-3.5 py-1.5 text-xs font-semibold whitespace-nowrap border transition-colors ${cat.active
                                        ? "border-primary bg-primary/10 text-primary"
                                        : "border-border text-muted-foreground hover:border-primary/50"
                                        }`}
                                >
                                    {cat.label}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Loading State */}
                    {isLoading && (
                        <div className="flex items-center justify-center py-20">
                            <Loader size={24} className="animate-spin text-muted-foreground" />
                        </div>
                    )}

                    {/* Error State */}
                    {isError && (
                        <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-4 mt-4">
                            <p className="text-sm text-muted-foreground">Failed to load campaigns</p>
                            <Button variant="outline" size="sm" onClick={() => window.location.reload()}>Try again</Button>
                        </div>
                    )}

                    {/* Empty State */}
                    {!isLoading && !isError && campaigns.length === 0 && (
                        <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-4 mt-4">
                            <Heart size={32} className="text-muted-foreground" />
                            <p className="text-sm text-muted-foreground">No campaigns yet</p>
                            <p className="text-xs text-muted-foreground">Be the first to start a campaign for your church.</p>
                        </div>
                    )}

                    {/* Campaign Grid + Right Panel */}
                    {!isLoading && !isError && campaigns.length > 0 && (
                        <div className="grid grid-cols-1 gap-5 px-4 pb-10 xl:grid-cols-[minmax(0,1fr)_300px]">
                            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                                {campaigns.map((campaign) => (
                                    <CampaignCard key={campaign.id} campaign={campaign} />
                                ))}
                            </div>
                            <CampaignsRightPanel campaigns={campaigns} />
                        </div>
                    )}
                </div>
            </div>
        </>
    )
}

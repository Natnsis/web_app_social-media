"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import Image from "next/image"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { Skeleton } from "@/components/ui/skeleton"
import {
    Dialog, DialogTrigger, DialogContent, DialogHeader,
    DialogTitle, DialogDescription, DialogFooter, DialogClose,
} from "@/components/ui/dialog"
import {
    Heart, Users, CalendarAlt, ArrowLeft,
    Church, Gift,
} from "nasicon-react/outline"
import { Loader, Sparkles, BarChart3, Clock, Share2 } from "lucide-react"
import { useCampaign, useCampaignContributions, useCampaignUpdates } from "@/hooks/use-campaigns"
import type { Campaign, CampaignContribution, CampaignUpdate } from "@/lib/api/campaigns"

function daysLeft(dateStr: string) {
    const diff = new Date(dateStr).getTime() - Date.now()
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)))
}

function getProgress(current: number, goal: number) {
    return Math.min(Math.round((current / goal) * 100), 100)
}

function DonateDialog({ campaign }: { campaign: Campaign }) {
    const [amount, setAmount] = useState<number | null>(null)
    const [customAmount, setCustomAmount] = useState("")
    const presetAmounts = [10, 25, 50, 100, 250]

    return (
        <Dialog>
            <DialogTrigger render={<Button size="lg" className="rounded-xl gap-2 w-full"><Heart size={16} />Donate Now</Button>} />
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

function CampaignDetailSkeleton() {
    return (
        <div className="space-y-4 p-4">
            <Skeleton className="h-8 w-24" />
            <Skeleton className="h-48 w-full rounded-2xl" />
            <div className="space-y-3">
                <Skeleton className="h-8 w-3/4" />
                <Skeleton className="h-4 w-1/2" />
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-4 w-full" />
                <Skeleton className="h-2 w-full" />
                <div className="flex justify-between">
                    <Skeleton className="h-4 w-24" />
                    <Skeleton className="h-4 w-24" />
                </div>
                <Skeleton className="h-10 w-full rounded-xl" />
            </div>
        </div>
    )
}

function CampaignInfoPanel({ campaign, contributions }: { campaign: Campaign; contributions: { name: string; initials: string; amount: number }[] }) {
    const progress = getProgress(campaign.currentBalance, campaign.goalAmount)
    const remaining = daysLeft(campaign.endsAt)

    return (
        <aside className="hidden h-full shrink-0 flex-col overflow-y-auto rounded-2xl border border-border bg-card p-4 xl:flex xl:w-80">
            <div className="rounded-xl bg-gradient-to-br from-primary to-primary/80 p-4 text-primary-foreground">
                <p className="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-primary-foreground/70">
                    <Sparkles size={13} />
                    Campaign Stats
                </p>
                <div className="mt-4 space-y-3">
                    <div>
                        <p className="text-2xl font-black">${campaign.currentBalance.toLocaleString()}</p>
                        <p className="text-[11px] text-primary-foreground/70">raised of ${campaign.goalAmount.toLocaleString()} goal</p>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <p className="text-lg font-black">{campaign.donorCount}</p>
                            <p className="text-[11px] text-primary-foreground/70">donors</p>
                        </div>
                        <div>
                            <p className="text-lg font-black">{remaining}</p>
                            <p className="text-[11px] text-primary-foreground/70">days left</p>
                        </div>
                    </div>
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <Gift size={14} className="text-primary" />
                    Top Donors
                </p>
                <div className="space-y-2">
                    {contributions.length === 0 && (
                        <p className="text-xs text-muted-foreground text-center py-4">No donations yet</p>
                    )}
                    {contributions.map((donor) => (
                        <div key={donor.name} className="flex items-center gap-2.5 rounded-xl border border-border bg-background p-2.5">
                            <Avatar className="size-8">
                                <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                    {donor.initials}
                                </AvatarFallback>
                            </Avatar>
                            <div className="flex-1 min-w-0">
                                <p className="text-xs font-semibold truncate">{donor.name}</p>
                                <p className="text-[11px] text-muted-foreground">${donor.amount.toLocaleString()} donated</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <BarChart3 size={14} className="text-primary" />
                    Progress
                </p>
                <div className="rounded-xl border border-border bg-background p-4 space-y-3">
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Percentage</span>
                        <span className="font-semibold text-primary">{progress}%</span>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Status</span>
                        <Badge variant="outline" className="text-[10px] px-2 py-0 h-5">{campaign.status}</Badge>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Start Date</span>
                        <span className="font-semibold">{new Date(campaign.startsAt).toLocaleDateString()}</span>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">End Date</span>
                        <span className="font-semibold">{new Date(campaign.endsAt).toLocaleDateString()}</span>
                    </div>
                </div>
            </div>

            <Separator />

            <DonateDialog campaign={campaign} />
        </aside>
    )
}

export default function CampaignDetailPage({ params }: { params: Promise<{ id: string }> }) {
    const router = useRouter()
    const [id, setId] = useState<string | null>(null)
    const { data, isLoading, isError } = useCampaign(id ?? "")
    const { data: contributionsData, isLoading: contribLoading } = useCampaignContributions(id ?? "")
    const { data: updatesData, isLoading: updatesLoading } = useCampaignUpdates(id ?? "")

    useEffect(() => {
        params.then((p) => setId(p.id))
    }, [params])

    if (!id) return null

    const campaign = data?.data
    const contributions = contributionsData?.data?.map((c: CampaignContribution) => ({
        name: c.fullName,
        initials: c.initials,
        amount: c.amount,
        date: c.createdAt,
    })) ?? []
    const updates: CampaignUpdate[] = updatesData?.data ?? []

    return (
        <div className="h-full overflow-y-auto bg-background">
            {/* Mobile layout */}
            <div className="lg:hidden">
                {isLoading && <CampaignDetailSkeleton />}

                {isError && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-4 mt-4">
                        <p className="text-sm text-muted-foreground">Failed to load campaign</p>
                        <Button variant="outline" size="sm" onClick={() => window.location.reload()}>Try again</Button>
                    </div>
                )}

                {!isLoading && !isError && !campaign && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-4 mt-4">
                        <Heart size={32} className="text-muted-foreground" />
                        <p className="text-sm text-muted-foreground">Campaign not found</p>
                        <Button variant="outline" size="sm" onClick={() => router.push("/campaigns")}>Back to campaigns</Button>
                    </div>
                )}

                {campaign && (
                    <>
                        <div className="sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-background/80 backdrop-blur-md px-3 py-2">
                            <Button variant="ghost" size="icon-sm" onClick={() => router.back()}>
                                <ArrowLeft size={20} />
                            </Button>
                            <h1 className="text-sm font-bold truncate">{campaign.title}</h1>
                            <Button variant="ghost" size="icon-sm" className="ml-auto">
                                <Share2 size={18} />
                            </Button>
                        </div>

                        <div className="relative h-48 bg-gradient-to-br from-primary to-primary/60">
                            {campaign.coverImageUrl && (
                                <Image src={campaign.coverImageUrl} alt={campaign.title} fill className="object-cover" />
                            )}
                            <div className="absolute inset-0 bg-black/20" />
                            <div className="absolute bottom-3 left-3 flex gap-2">
                                <Badge className="bg-white/20 text-white border-0 backdrop-blur-sm text-[10px]">
                                    {campaign.status}
                                </Badge>
                            </div>
                        </div>

                        <div className="px-4 pb-24 space-y-5 -mt-6 relative z-10">
                            <div className="rounded-2xl border border-border bg-card p-4 space-y-4">
                                <div>
                                    <h2 className="text-lg font-black leading-snug">{campaign.title}</h2>
                                    <div className="flex items-center gap-1.5 mt-1.5">
                                        <Church size={14} className="text-muted-foreground shrink-0" />
                                        <span className="text-xs text-muted-foreground">{campaign.church.name}</span>
                                    </div>
                                </div>

                                <p className="text-sm text-muted-foreground leading-relaxed">{campaign.description}</p>

                                <div className="space-y-1.5">
                                    <div className="flex items-center justify-between text-sm">
                                        <span className="font-bold">${campaign.currentBalance.toLocaleString()}</span>
                                        <span className="text-muted-foreground">of ${campaign.goalAmount.toLocaleString()}</span>
                                    </div>
                                    <div className="h-2.5 rounded-full bg-muted overflow-hidden">
                                        <div
                                            className="h-full rounded-full bg-primary transition-all duration-500"
                                            style={{ width: `${getProgress(campaign.currentBalance, campaign.goalAmount)}%` }}
                                        />
                                    </div>
                                    <div className="flex items-center justify-between text-xs">
                                        <span className="text-muted-foreground">{getProgress(campaign.currentBalance, campaign.goalAmount)}% funded</span>
                                        <span className="flex items-center gap-1 font-semibold text-amber-600">
                                            <CalendarAlt size={12} />
                                            {daysLeft(campaign.endsAt)} days left
                                        </span>
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-3">
                                    <div className="rounded-xl border border-border bg-background p-3 text-center">
                                        <Users size={16} className="mx-auto text-primary mb-1" />
                                        <p className="text-lg font-black">{campaign.donorCount}</p>
                                        <p className="text-[11px] text-muted-foreground">Donors</p>
                                    </div>
                                    <div className="rounded-xl border border-border bg-background p-3 text-center">
                                        <Gift size={16} className="mx-auto text-primary mb-1" />
                                        <p className="text-lg font-black">{campaign._count.contributions}</p>
                                        <p className="text-[11px] text-muted-foreground">Contributions</p>
                                    </div>
                                </div>

                                <DonateDialog campaign={campaign} />
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
                                <h3 className="text-sm font-bold flex items-center gap-1.5">
                                    <Users size={15} className="text-primary" />
                                    Recent Donors
                                </h3>
                                <div className="space-y-2">
                                    {contribLoading && (
                                        <div className="flex items-center justify-center py-4">
                                            <Loader size={16} className="animate-spin text-muted-foreground" />
                                        </div>
                                    )}
                                    {!contribLoading && contributions.length === 0 && (
                                        <p className="text-xs text-muted-foreground text-center py-4">No donations yet</p>
                                    )}
                                    {!contribLoading && contributions.map((donor) => (
                                        <div key={donor.name} className="flex items-center gap-2.5">
                                            <Avatar className="size-8">
                                                <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                                    {donor.initials}
                                                </AvatarFallback>
                                            </Avatar>
                                            <div className="flex-1 min-w-0">
                                                <p className="text-xs font-semibold">{donor.name}</p>
                                                <p className="text-[11px] text-muted-foreground">{new Date(donor.date).toLocaleDateString()}</p>
                                            </div>
                                            <span className="text-xs font-bold">${donor.amount}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
                                <h3 className="text-sm font-bold flex items-center gap-1.5">
                                    <Clock size={15} className="text-primary" />
                                    Updates
                                </h3>
                                <div className="space-y-4">
                                    {updatesLoading && (
                                        <div className="flex items-center justify-center py-4">
                                            <Loader size={16} className="animate-spin text-muted-foreground" />
                                        </div>
                                    )}
                                    {!updatesLoading && updates.length === 0 && (
                                        <p className="text-xs text-muted-foreground text-center py-4">No updates yet</p>
                                    )}
                                    {!updatesLoading && updates.map((update, idx) => (
                                        <div key={update.id} className="space-y-1">
                                            <div className="flex items-center justify-between">
                                                <p className="text-xs font-semibold">{update.title}</p>
                                                <span className="text-[10px] text-muted-foreground">{new Date(update.createdAt).toLocaleDateString()}</span>
                                            </div>
                                            <p className="text-xs text-muted-foreground leading-relaxed">{update.body}</p>
                                            {idx < updates.length - 1 && <Separator />}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    </>
                )}
            </div>

            {/* Desktop layout */}
            <div className="hidden lg:block h-full">
                {isLoading && (
                    <div className="flex items-center justify-center h-full">
                        <Loader size={24} className="animate-spin text-muted-foreground" />
                    </div>
                )}

                {isError && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-auto mt-20 max-w-md">
                        <p className="text-sm text-muted-foreground">Failed to load campaign</p>
                        <Button variant="outline" size="sm" onClick={() => window.location.reload()}>Try again</Button>
                    </div>
                )}

                {!isLoading && !isError && !campaign && (
                    <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center mx-auto mt-20 max-w-md">
                        <Heart size={32} className="text-muted-foreground" />
                        <p className="text-sm text-muted-foreground">Campaign not found</p>
                        <Button variant="outline" size="sm" onClick={() => router.push("/campaigns")}>Back to campaigns</Button>
                    </div>
                )}

                {campaign && (
                    <div className="mx-auto grid h-full max-w-[1500px] grid-cols-[minmax(0,1fr)_320px] gap-5 py-4 px-4">
                        <section className="min-w-0 overflow-y-auto [scrollbar-width:none] [&::-webkit-scrollbar]:hidden space-y-4 pb-10">
                            <div className="relative h-56 rounded-2xl overflow-hidden bg-gradient-to-br from-primary to-primary/60">
                                {campaign.coverImageUrl && (
                                    <Image src={campaign.coverImageUrl} alt={campaign.title} fill className="object-cover" />
                                )}
                                <div className="absolute inset-0 bg-black/20" />
                                <div className="absolute bottom-4 left-4">
                                    <Badge className="bg-white/20 text-white border-0 backdrop-blur-sm">
                                        {campaign.status}
                                    </Badge>
                                </div>
                            </div>

                            <div>
                                <h1 className="text-2xl font-black">{campaign.title}</h1>
                                <div className="flex items-center gap-1.5 mt-1.5">
                                    <Church size={16} className="text-muted-foreground shrink-0" />
                                    <span className="text-sm text-muted-foreground">{campaign.church.name}</span>
                                </div>
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-4">
                                <div className="space-y-1.5">
                                    <div className="flex items-center justify-between text-lg">
                                        <span className="font-black">${campaign.currentBalance.toLocaleString()}</span>
                                        <span className="text-muted-foreground">of ${campaign.goalAmount.toLocaleString()}</span>
                                    </div>
                                    <div className="h-3 rounded-full bg-muted overflow-hidden">
                                        <div
                                            className="h-full rounded-full bg-primary transition-all duration-500"
                                            style={{ width: `${getProgress(campaign.currentBalance, campaign.goalAmount)}%` }}
                                        />
                                    </div>
                                    <div className="flex items-center justify-between text-sm">
                                        <span className="text-muted-foreground">{getProgress(campaign.currentBalance, campaign.goalAmount)}% funded</span>
                                        <span className="flex items-center gap-1 font-semibold text-amber-600">
                                            <CalendarAlt size={14} />
                                            {daysLeft(campaign.endsAt)} days left
                                        </span>
                                    </div>
                                </div>

                                <div className="grid grid-cols-3 gap-3">
                                    <div className="rounded-xl border border-border bg-background p-3 text-center">
                                        <p className="text-lg font-black">{campaign.donorCount}</p>
                                        <p className="text-[11px] text-muted-foreground">Donors</p>
                                    </div>
                                    <div className="rounded-xl border border-border bg-background p-3 text-center">
                                        <p className="text-lg font-black">{campaign._count.contributions}</p>
                                        <p className="text-[11px] text-muted-foreground">Contributions</p>
                                    </div>
                                    <div className="rounded-xl border border-border bg-background p-3 text-center">
                                        <p className="text-lg font-black">{daysLeft(campaign.endsAt)}</p>
                                        <p className="text-[11px] text-muted-foreground">Days Left</p>
                                    </div>
                                </div>

                                <DonateDialog campaign={campaign} />
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
                                <h3 className="text-sm font-bold">About This Campaign</h3>
                                <p className="text-sm text-muted-foreground leading-relaxed">{campaign.description}</p>
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
                                <h3 className="text-sm font-bold flex items-center gap-1.5">
                                    <Users size={15} className="text-primary" />
                                    Recent Donors
                                </h3>
                                <div className="space-y-2">
                                    {contribLoading && (
                                        <div className="flex items-center justify-center py-4">
                                            <Loader size={16} className="animate-spin text-muted-foreground" />
                                        </div>
                                    )}
                                    {!contribLoading && contributions.length === 0 && (
                                        <p className="text-xs text-muted-foreground text-center py-4">No donations yet</p>
                                    )}
                                    {!contribLoading && contributions.map((donor) => (
                                        <div key={donor.name} className="flex items-center gap-2.5">
                                            <Avatar className="size-8">
                                                <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                                    {donor.initials}
                                                </AvatarFallback>
                                            </Avatar>
                                            <div className="flex-1 min-w-0">
                                                <p className="text-xs font-semibold">{donor.name}</p>
                                                <p className="text-[11px] text-muted-foreground">{new Date(donor.date).toLocaleDateString()}</p>
                                            </div>
                                            <span className="text-xs font-bold">${donor.amount}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="rounded-2xl border border-border bg-card p-4 space-y-3">
                                <h3 className="text-sm font-bold flex items-center gap-1.5">
                                    <Clock size={15} className="text-primary" />
                                    Updates
                                </h3>
                                <div className="space-y-4">
                                    {updatesLoading && (
                                        <div className="flex items-center justify-center py-4">
                                            <Loader size={16} className="animate-spin text-muted-foreground" />
                                        </div>
                                    )}
                                    {!updatesLoading && updates.length === 0 && (
                                        <p className="text-xs text-muted-foreground text-center py-4">No updates yet</p>
                                    )}
                                    {!updatesLoading && updates.map((update, idx) => (
                                        <div key={update.id} className="space-y-1">
                                            <div className="flex items-center justify-between">
                                                <p className="text-sm font-semibold">{update.title}</p>
                                                <span className="text-[11px] text-muted-foreground">{new Date(update.createdAt).toLocaleDateString()}</span>
                                            </div>
                                            <p className="text-sm text-muted-foreground leading-relaxed">{update.body}</p>
                                            {idx < updates.length - 1 && <Separator />}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </section>
                        <CampaignInfoPanel campaign={campaign} contributions={contributions} />
                    </div>
                )}
            </div>
        </div>
    )
}

"use client"

import { useCallback, useEffect, useState } from "react"
import Link from "next/link"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { useCampaigns } from "@/hooks/use-campaigns"
import { useEvents } from "@/hooks/use-events"
import { useNearbyChurches, useToggleFollowChurch, useFollowingChurches } from "@/hooks/use-nearby-churches"
import { useLiveStreams } from "@/hooks/use-livestream"
import { useGeolocation } from "@/hooks/use-geolocation"
import { Search, BarChart3, Radio } from "lucide-react"
import {
    LocationPin, TowerBroadcast, Church, Heart,
    CalendarAlt, ChevronRight, Users, Globe,
} from "nasicon-react/outline"
import type { Campaign } from "@/lib/api/campaigns"
import type { EventItem } from "@/lib/api/events"
import type { NearbyChurch } from "@/lib/api/churches"
import type { LiveStream } from "@/lib/api/livestream"

const desktopTrends = [
    { label: "Sunday Recap", value: "18.4k views" },
    { label: "Youth Worship", value: "7 live rooms" },
    { label: "Giving Campaign", value: "82% funded" },
    { label: "Bible Study", value: "1.2k attending" },
]

/* ── Helpers ── */

function getInitials(name: string) {
    return name
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
}

function formatEventDate(dateStr: string) {
    const d = new Date(dateStr)
    return {
        month: d.toLocaleString("en-US", { month: "short" }).toUpperCase(),
        day: d.getDate(),
    }
}

function formatEventTime(dateStr: string) {
    const d = new Date(dateStr)
    return d.toLocaleString("en-US", { hour: "numeric", minute: "2-digit", hour12: true })
}

function daysLeft(endsAt: string) {
    return Math.max(0, Math.ceil((new Date(endsAt).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
}

function campaignProgress(campaign: Campaign) {
    return Math.min(100, Math.round((campaign.currentBalance / campaign.goalAmount) * 100))
}

/* ── Section: Live Now ── */

function LiveNowSection() {
    const { data: liveData } = useLiveStreams()
    const streams = liveData?.data ?? []
    return (
        <div>
            <div className="mb-2.5 flex items-center justify-between">
                <h2 className="flex items-center gap-1.5 text-sm font-bold">
                    <Radio size={15} className="text-primary" /> Live Now
                </h2>
                <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">View all</Button>
            </div>
            <div className="flex h-fit gap-4 overflow-x-auto px-1 py-1">
                {streams.length === 0 && (
                    <p className="text-xs text-muted-foreground px-1 py-4">No live streams right now</p>
                )}
                {streams.map((u: LiveStream) => (
                    <Link key={u.id} href={`/live/${u.id}`} className="relative flex shrink-0 flex-col items-center gap-1">
                        <div className="relative">
                            <Avatar className="size-14 ring-2 ring-red-500 ring-offset-1">
                                <AvatarFallback className="bg-muted text-xs font-medium">{getInitials(u.church.name)}</AvatarFallback>
                            </Avatar>
                            <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 flex items-center gap-0.5 rounded-full bg-red-500 px-1.5 py-0.5">
                                <div className="size-1 rounded-full bg-white animate-pulse" />
                                <span className="text-[8px] font-bold text-white">LIVE</span>
                            </div>
                        </div>
                        <span className="mt-2 w-14 truncate text-center text-[10px] text-muted-foreground">{u.church.name}</span>
                    </Link>
                ))}
            </div>
        </div>
    )
}

/* ── Section: Suggested Churches ── */

function SuggestedChurchesSection() {
    const { latitude, longitude } = useGeolocation()
    const { data: nearbyData } = useNearbyChurches(latitude, longitude, 50)
    const churches = nearbyData?.data ?? []
    return (
        <div>
            <div className="mb-2.5 flex items-center justify-between">
                <h2 className="flex items-center gap-1.5 text-sm font-bold">
                    <Church size={15} className="text-primary" /> Suggested Churches
                </h2>
                <Link href="/nearby-churches">
                    <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">See all</Button>
                </Link>
            </div>
            <div className="flex gap-3 overflow-x-auto px-1 py-1">
                {churches.length === 0 && (
                    <p className="text-xs text-muted-foreground px-1 py-4">No churches found</p>
                )}
                {churches.slice(0, 6).map((c: NearbyChurch) => (
                    <Link key={c.id} href={`/churches/${c.id}`} className="group w-44 shrink-0">
                        <div className="overflow-hidden rounded-xl border border-border bg-card transition-colors group-hover:border-primary/30">
                            <div className="flex h-24 items-center justify-center bg-gradient-to-br from-primary/20 to-primary/5">
                                <Avatar className="size-12 ring-2 ring-background">
                                    <AvatarFallback className="bg-primary/30 text-primary text-sm font-bold">{getInitials(c.name)}</AvatarFallback>
                                </Avatar>
                            </div>
                            <div className="p-3">
                                <p className="truncate text-sm font-bold">{c.name}</p>
                                <p className="flex items-center gap-1 text-[10px] text-muted-foreground">
                                    <LocationPin size={11} className="text-primary" /> {c.address}
                                </p>
                                <p className="mt-1.5 flex items-center gap-1 text-[10px] text-muted-foreground">
                                    <LocationPin size={11} className="text-primary" /> {c.distance.toFixed(1)} km
                                </p>
                            </div>
                        </div>
                    </Link>
                ))}
            </div>
        </div>
    )
}

/* ── Section: Trending Campaigns ── */

function CampaignCard({ campaign }: { campaign: Campaign }) {
    const progress = campaignProgress(campaign)
    const remaining = daysLeft(campaign.endsAt)

    return (
        <div className="rounded-xl border border-border bg-card p-4">
            {campaign.coverImageUrl && (
                <div className="mb-3 h-32 w-full overflow-hidden rounded-lg bg-muted">
                    <img src={campaign.coverImageUrl} alt={campaign.title} className="h-full w-full object-cover" />
                </div>
            )}
            <div className="flex items-start justify-between gap-2">
                <div className="min-w-0 flex-1">
                    <h3 className="truncate text-sm font-bold">{campaign.title}</h3>
                    <p className="mt-0.5 truncate text-xs text-muted-foreground">{campaign.church.name}</p>
                </div>
                <span className="shrink-0 text-xs font-bold text-primary">{progress}%</span>
            </div>
            <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-muted">
                <div className="h-full rounded-full bg-primary transition-all" style={{ width: `${progress}%` }} />
            </div>
            <div className="mt-2 flex items-center justify-between">
                <p className="text-[10px] text-muted-foreground">
                    {(campaign.currentBalance || 0).toLocaleString()} raised of {(campaign.goalAmount || 0).toLocaleString()}
                </p>
                <span className="rounded-full bg-muted px-2 py-0.5 text-[10px] font-semibold">{remaining}d left</span>
            </div>
            <Link href={`/campaigns/${campaign.id}`}>
                <Button variant="outline" size="xs" className="mt-3 w-full rounded-full text-[10px]">
                    <Heart size={12} className="mr-1" /> Donate
                </Button>
            </Link>
        </div>
    )
}

function CampaignsSection() {
    const { data, isLoading, isError, refetch } = useCampaigns()
    const campaigns = data?.data ?? []

    return (
        <div>
            <div className="mb-2.5 flex items-center justify-between">
                <h2 className="flex items-center gap-1.5 text-sm font-bold">
                    <TowerBroadcast size={15} className="text-primary" /> Trending Campaigns
                </h2>
                <Link href="/campaigns">
                    <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">View all</Button>
                </Link>
            </div>

            {isLoading && (
                <div className="space-y-3">
                    {[1, 2].map((i) => (
                        <div key={i} className="animate-pulse rounded-xl border border-border bg-card p-4">
                            <div className="mb-3 h-32 rounded-lg bg-muted" />
                            <div className="h-4 w-3/4 rounded bg-muted" />
                            <div className="mt-2 h-3 w-1/2 rounded bg-muted" />
                            <div className="mt-3 h-1.5 w-full rounded bg-muted" />
                            <div className="mt-2 flex justify-between">
                                <div className="h-3 w-24 rounded bg-muted" />
                                <div className="h-5 w-14 rounded-full bg-muted" />
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {isError && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <p className="text-xs text-muted-foreground">Couldn&apos;t load campaigns</p>
                    <Button variant="outline" size="xs" onClick={() => refetch()}>Try again</Button>
                </div>
            )}

            {!isLoading && !isError && campaigns.length === 0 && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <TowerBroadcast size={24} className="text-muted-foreground" />
                    <p className="text-xs text-muted-foreground">No campaigns yet</p>
                </div>
            )}

            {!isLoading && !isError && campaigns.length > 0 && (
                <div className="space-y-3">
                    {campaigns.slice(0, 3).map((campaign) => (
                        <CampaignCard key={campaign.id} campaign={campaign} />
                    ))}
                </div>
            )}
        </div>
    )
}

/* ── Section: Upcoming Events ── */

function EventCard({ event }: { event: EventItem }) {
    const { month, day } = formatEventDate(event.startDate)
    const time = formatEventTime(event.startDate)

    return (
        <div className="flex gap-3 rounded-xl border border-border bg-card p-3">
            <div className="flex w-11 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary">
                <p className="text-[9px] font-bold uppercase leading-tight">{month}</p>
                <p className="text-lg font-black leading-tight">{day}</p>
            </div>
            <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-bold">{event.title}</p>
                <p className="text-xs text-muted-foreground">{event.church.name}</p>
                <div className="mt-1 flex items-center gap-3 text-[10px] text-muted-foreground">
                    <span>{time}</span>
                    {event.location && (
                        <span className="flex items-center gap-1">
                            <LocationPin size={11} /> {event.location}
                        </span>
                    )}
                    <span className="flex items-center gap-1">
                        <Users size={11} /> {event.attendeeCount}
                    </span>
                </div>
            </div>
            <ChevronRight size={16} className="mt-1 shrink-0 text-muted-foreground" />
        </div>
    )
}

function EventsSection() {
    const { data, isLoading, isError, refetch } = useEvents(1, 20)
    const events = data?.data ?? []

    return (
        <div>
            <div className="mb-2.5 flex items-center justify-between">
                <h2 className="flex items-center gap-1.5 text-sm font-bold">
                    <CalendarAlt size={15} className="text-primary" /> Upcoming Events
                </h2>
                <Link href="/events">
                    <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">View all</Button>
                </Link>
            </div>

            {isLoading && (
                <div className="space-y-3">
                    {[1, 2].map((i) => (
                        <div key={i} className="animate-pulse rounded-xl border border-border bg-card p-3">
                            <div className="flex gap-3">
                                <div className="size-11 shrink-0 rounded-lg bg-muted" />
                                <div className="flex-1 space-y-2">
                                    <div className="h-4 w-3/4 rounded bg-muted" />
                                    <div className="h-3 w-1/2 rounded bg-muted" />
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            )}

            {isError && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <p className="text-xs text-muted-foreground">Couldn&apos;t load events</p>
                    <Button variant="outline" size="xs" onClick={() => refetch()}>Try again</Button>
                </div>
            )}

            {!isLoading && !isError && events.length === 0 && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <CalendarAlt size={24} className="text-muted-foreground" />
                    <p className="text-xs text-muted-foreground">No upcoming events</p>
                </div>
            )}

            {!isLoading && !isError && events.length > 0 && (
                <div className="space-y-3">
                    {events.slice(0, 3).map((event) => (
                        <EventCard key={event.id} event={event} />
                    ))}
                </div>
            )}
        </div>
    )
}

/* ── Section: Nearby Churches ── */

function NearbyChurchesSection() {
    const { latitude, longitude } = useGeolocation()
    const { data, isLoading, isError, refetch } = useNearbyChurches(latitude, longitude, 50)
    const toggleFollow = useToggleFollowChurch()
    const { data: followingData } = useFollowingChurches()
    const churches = data?.data ?? []
    const followingIds = followingData?.data?.map((c) => c.id) ?? []
    const [followed, setFollowed] = useState<Set<string>>(new Set())

    useEffect(() => {
        if (followingIds.length > 0) {
            setFollowed(new Set(followingIds))
        }
    }, [followingIds])

    const handleToggleFollow = useCallback((id: string) => {
        const following = followed.has(id)
        setFollowed((prev) => {
            const next = new Set(prev)
            if (following) next.delete(id)
            else next.add(id)
            return next
        })
        toggleFollow.mutate({ id, following })
    }, [followed, toggleFollow])

    return (
        <div>
            <div className="mb-2.5 flex items-center justify-between">
                <h2 className="flex items-center gap-1.5 text-sm font-bold">
                    <LocationPin size={15} className="text-primary" /> Nearby Churches
                </h2>
                <Link href="/nearby-churches">
                    <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">See all</Button>
                </Link>
            </div>

            {/* Mini map preview */}
            <Link href="/nearby-churches" className="mb-3 block overflow-hidden rounded-xl border border-border">
                <div className="relative flex h-32 items-center justify-center bg-gradient-to-br from-primary/10 to-primary/5">
                    <Globe size={32} className="text-primary/40" />
                    <p className="absolute text-xs font-medium text-primary">Explore on map</p>
                    <div className="absolute bottom-2 left-2 right-2 flex flex-wrap gap-1">
                        {churches.slice(0, 5).map((c) => (
                            <span key={c.id} className="rounded-full bg-background/80 px-2 py-0.5 text-[9px] font-medium text-foreground backdrop-blur-sm">
                                {c.name}
                            </span>
                        ))}
                    </div>
                </div>
            </Link>

            {isLoading && (
                <div className="flex gap-3 overflow-x-auto px-1 py-1">
                    {[1, 2, 3].map((i) => (
                        <div key={i} className="flex w-44 shrink-0 animate-pulse flex-col gap-2 rounded-xl border border-border bg-card p-3">
                            <div className="flex items-center gap-2.5">
                                <div className="size-10 shrink-0 rounded-full bg-muted" />
                                <div className="h-4 flex-1 rounded bg-muted" />
                            </div>
                            <div className="h-3 w-20 rounded bg-muted" />
                            <div className="h-6 w-full rounded-full bg-muted" />
                        </div>
                    ))}
                </div>
            )}

            {isError && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <p className="text-xs text-muted-foreground">Couldn&apos;t find nearby churches</p>
                    <Button variant="outline" size="xs" onClick={() => refetch()}>Try again</Button>
                </div>
            )}

            {!isLoading && !isError && churches.length === 0 && (
                <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-6 text-center">
                    <LocationPin size={24} className="text-muted-foreground" />
                    <p className="text-xs text-muted-foreground">No churches nearby</p>
                </div>
            )}

            {!isLoading && !isError && churches.length > 0 && (
                <div className="flex gap-3 overflow-x-auto px-1 py-1">
                    {churches.slice(0, 6).map((c) => (
                        <div key={c.id} className="flex w-44 shrink-0 flex-col gap-2 rounded-xl border border-border bg-card p-3">
                            <div className="flex items-center gap-2.5">
                                <Avatar size="sm" className="shrink-0">
                                    <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-semibold">
                                        {getInitials(c.name)}
                                    </AvatarFallback>
                                </Avatar>
                                <p className="truncate text-xs font-semibold">{c.name}</p>
                            </div>
                            <p className="flex items-center gap-1 text-[10px] text-muted-foreground">
                                <LocationPin size={12} className="text-primary" /> {c.distance.toFixed(1)} km
                            </p>
                            <Button
                                variant={followed.has(c.id) ? "outline" : "default"}
                                size="xs"
                                className="w-full rounded-full text-[10px]"
                                onClick={() => handleToggleFollow(c.id)}
                            >
                                {followed.has(c.id) ? "Following" : "Follow"}
                            </Button>
                        </div>
                    ))}
                </div>
            )}
        </div>
    )
}

/* ── Desktop right panel ── */

function DesktopRightPanel() {
    const { data: eventsData, isLoading: eventsLoading } = useEvents(1, 5)
    const events = eventsData?.data ?? []

    const { latitude, longitude } = useGeolocation()
    const { data: churchesData } = useNearbyChurches(latitude, longitude, 50)
    const churches = churchesData?.data ?? []

    return (
        <aside className="h-full overflow-y-auto rounded-2xl border border-border bg-card p-4 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
            {/* Trending Now */}
            <div>
                <div className="mb-3 flex items-center justify-between">
                    <p className="flex items-center gap-1.5 text-xs font-bold">
                        <BarChart3 size={14} className="text-primary" /> Trending Now
                    </p>
                    <button className="text-[11px] text-primary hover:underline">See all</button>
                </div>
                <div className="space-y-2">
                    {desktopTrends.map((trend) => (
                        <div key={trend.label} className="flex items-center justify-between rounded-xl bg-muted/45 px-3 py-2.5">
                            <p className="text-xs font-semibold">{trend.label}</p>
                            <p className="text-[11px] text-muted-foreground">{trend.value}</p>
                        </div>
                    ))}
                </div>
            </div>

            {/* Upcoming Events */}
            <div className="mt-6">
                <div className="mb-3 flex items-center justify-between">
                    <p className="flex items-center gap-1.5 text-xs font-bold">
                        <CalendarAlt size={13} className="text-primary" /> Upcoming Events
                    </p>
                    <Link href="/events" className="text-[11px] text-primary hover:underline">View All</Link>
                </div>
                <div className="space-y-2.5">
                    {eventsLoading && (
                        <>
                            {[1, 2].map((i) => (
                                <div key={i} className="animate-pulse rounded-xl border border-border bg-background p-3">
                                    <div className="flex gap-3">
                                        <div className="size-10 rounded-lg bg-muted" />
                                        <div className="flex-1 space-y-2">
                                            <div className="h-3 w-3/4 rounded bg-muted" />
                                            <div className="h-2 w-1/2 rounded bg-muted" />
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </>
                    )}
                    {!eventsLoading && events.slice(0, 3).map((ev) => {
                        const { month, day } = formatEventDate(ev.startDate)
                        return (
                            <div key={ev.id} className="flex gap-3 rounded-xl border border-border bg-background p-3">
                                <div className="flex w-10 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary">
                                    <p className="text-[9px] font-bold uppercase leading-tight">{month}</p>
                                    <p className="text-base font-black leading-tight">{day}</p>
                                </div>
                                <div className="min-w-0">
                                    <p className="truncate text-xs font-semibold">{ev.title}</p>
                                    <p className="text-[10px] text-muted-foreground">{ev.church.name}</p>
                                </div>
                            </div>
                        )
                    })}
                    {!eventsLoading && events.length === 0 && (
                        <p className="text-xs text-muted-foreground text-center py-4">No upcoming events</p>
                    )}
                </div>
            </div>

            {/* Nearby Churches */}
            <div className="mt-6">
                <p className="mb-3 flex items-center gap-1.5 text-xs font-bold">
                    <LocationPin size={13} className="text-primary" /> Nearby Churches
                </p>
                <div className="space-y-2">
                    {churches.slice(0, 4).map((c) => (
                        <div key={c.id} className="flex items-center gap-2.5 rounded-xl border border-border bg-background p-3">
                            <Avatar size="sm">
                                <AvatarFallback className="bg-primary/20 text-primary text-[10px]">
                                    {getInitials(c.name)}
                                </AvatarFallback>
                            </Avatar>
                            <div className="min-w-0 flex-1">
                                <p className="truncate text-xs font-semibold">{c.name}</p>
                                <p className="text-[10px] text-muted-foreground">{c.distance.toFixed(1)} km</p>
                            </div>
                        </div>
                    ))}
                    <Link href="/nearby-churches">
                        <Button variant="outline" size="xs" className="w-full rounded-xl text-xs">Open Local Map</Button>
                    </Link>
                </div>
            </div>
        </aside>
    )
}

/* ── Mobile explore content ── */

function MobileExploreContent() {
    return (
        <div className="space-y-6 pb-24">
            {/* Search bar */}
            <div className="relative">
                <Search size={17} className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground" />
                <Input
                    placeholder="Search churches, events, campaigns..."
                    className="h-11 rounded-xl border-border bg-card pl-11 pr-4 text-sm"
                />
            </div>

            <LiveNowSection />
            <SuggestedChurchesSection />
            <CampaignsSection />
            <EventsSection />
            <NearbyChurchesSection />
        </div>
    )
}

/* ── Desktop explore content ── */

function DesktopExploreContent() {
    return (
        <div className="mx-auto grid h-full max-w-[1500px] grid-cols-[minmax(0,1fr)_320px] gap-5 py-4">
            <section className="min-w-0 overflow-y-auto px-2 pb-10 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
                <div className="space-y-6">
                    <LiveNowSection />
                    <SuggestedChurchesSection />
                    <CampaignsSection />
                    <EventsSection />
                    <NearbyChurchesSection />
                </div>
            </section>
            <DesktopRightPanel />
        </div>
    )
}

/* ── Page ── */

export default function ExplorePage() {
    return (
        <>
            <div className="hidden h-full overflow-hidden bg-background lg:block">
                <DesktopExploreContent />
            </div>

            <div className="relative flex h-full flex-col overflow-hidden lg:hidden">
                <div className="flex-1 overflow-y-auto px-3 md:px-5">
                    <MobileExploreContent />
                </div>
            </div>
        </>
    )
}

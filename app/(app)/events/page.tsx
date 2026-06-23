"use client"

import { useState } from "react"
import Link from "next/link"
import { ChevronLeft, Calendar } from "lucide-react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { useAuthStore } from "@/lib/store/auth"
import { useEvents } from "@/hooks/use-events"
import {
    Heart, Bookmark, Eye, MessageSquare, CornerUpRight, Sparkles,
} from "nasicon-react/outline"
import { DotsHorizontal, CirclePlus } from "nasicon-react/solid"
import type { EventItem } from "@/types"

const filterPills = ["All", "Upcoming", "Ongoing", "Completed"]

function formatEventDate(event: EventItem) {
    const start = new Date(event.startDate)
    const end = new Date(event.endDate)
    const dateStr = start.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })
    const timeStr = start.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })
    const sameDay = start.toDateString() === end.toDateString()
    if (sameDay) return `${dateStr} at ${timeStr}`
    const endDateStr = end.toLocaleDateString("en-US", { month: "short", day: "numeric" })
    return `${dateStr} - ${endDateStr}`
}

function getInitials(name: string) {
    return name.split(" ").map(n => n[0]).join("").toUpperCase().slice(0, 2)
}

function abbreviate(n: number) {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "m"
    if (n >= 1_000) return (n / 1_000).toFixed(1) + "k"
    return String(n)
}

/* ── Right Panel ── */

function EventsRightPanel({ events: evts }: { events: EventItem[] }) {
    const totalEvents = evts.length
    const upcoming = evts.filter((e) => e.status === "upcoming").length
    const ongoing = evts.filter((e) => e.status === "ongoing").length
    const completed = evts.filter((e) => e.status === "completed").length
    const categoryLabels = ["All", "Upcoming", "Ongoing", "Completed"]

    return (
        <aside className="hidden h-full shrink-0 flex-col overflow-y-auto rounded-2xl border border-border bg-card p-4 xl:flex">
            <div className="rounded-xl bg-gradient-to-br from-primary to-primary/80 p-4 text-primary-foreground">
                <p className="flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-wider text-primary-foreground/70">
                    <Sparkles size={13} />
                    Event Overview
                </p>
                <div className="mt-4 space-y-3">
                    <div>
                        <p className="text-2xl font-black">{totalEvents}</p>
                        <p className="text-[11px] text-primary-foreground/70">total events</p>
                    </div>
                    <div className="grid grid-cols-3 gap-3">
                        <div>
                            <p className="text-lg font-black">{upcoming}</p>
                            <p className="text-[11px] text-primary-foreground/70">upcoming</p>
                        </div>
                        <div>
                            <p className="text-lg font-black">{ongoing}</p>
                            <p className="text-[11px] text-primary-foreground/70">ongoing</p>
                        </div>
                        <div>
                            <p className="text-lg font-black">{completed}</p>
                            <p className="text-[11px] text-primary-foreground/70">past</p>
                        </div>
                    </div>
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <Calendar size={14} className="text-primary" />
                    Categories
                </p>
                <div className="space-y-1">
                    {categoryLabels.map((cat) => (
                        <button
                            key={cat}
                            className={`flex w-full items-center justify-between rounded-xl px-3 py-2 text-xs transition-colors ${
                                cat === "All"
                                    ? "bg-primary/10 font-semibold text-primary"
                                    : "text-muted-foreground hover:bg-muted hover:text-foreground"
                            }`}
                        >
                            <span>{cat}</span>
                        </button>
                    ))}
                </div>
            </div>

            <Separator />

            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3">
                    <Sparkles size={14} className="text-primary" />
                    Upcoming Events
                </p>
                <div className="space-y-2">
                    {evts.filter((e) => e.status === "upcoming").slice(0, 3).map((e) => (
                        <div key={e.id} className="rounded-xl border border-border bg-background p-2.5">
                            <div className="flex items-center gap-2.5">
                                <Avatar className="size-8">
                                    <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                        {getInitials(e.title)}
                                    </AvatarFallback>
                                </Avatar>
                                <div className="flex-1 min-w-0">
                                    <p className="text-xs font-semibold truncate">{e.title}</p>
                                    <p className="text-[11px] text-muted-foreground">{formatEventDate(e)}</p>
                                </div>
                            </div>
                        </div>
                    ))}
                    {evts.filter((e) => e.status === "upcoming").length === 0 && (
                        <p className="text-[11px] text-muted-foreground text-center py-3">No upcoming events</p>
                    )}
                </div>
            </div>
        </aside>
    )
}

/* ── Main Page ── */

function statusFilter(events: EventItem[], filter: string) {
    if (filter === "All") return events
    const statusMap: Record<string, string> = {
        Upcoming: "upcoming",
        Ongoing: "ongoing",
        Completed: "completed",
    }
    return events.filter((e) => e.status === statusMap[filter])
}

export default function EventsPage() {
    const { user } = useAuthStore()
    const [activeFilter, setActiveFilter] = useState("All")
    const { data: eventsData, isLoading, isError } = useEvents(1, 50, undefined, true)
    const allEvents = eventsData?.data ?? []

    const filteredEvents = statusFilter(allEvents, activeFilter)

    return (
        <div className="relative flex h-full flex-col overflow-hidden">
            <header className="flex shrink-0 items-center gap-2 px-4 py-3">
                <Link href="/">
                    <Button variant="ghost" size="icon-sm" aria-label="Back">
                        <ChevronLeft size={22} />
                    </Button>
                </Link>
                <div className="flex items-center gap-2">
                    <Calendar size={20} className="text-primary" />
                    <h1 className="text-lg font-bold">Events</h1>
                </div>
            </header>

            <div className="flex-1 overflow-y-auto pb-24">
                <div className="flex gap-2 overflow-x-auto px-4 py-2">
                    {filterPills.map((pill) => (
                        <button
                            key={pill}
                            onClick={() => setActiveFilter(pill)}
                            className={`shrink-0 rounded-full px-4 py-1.5 text-xs font-semibold transition-colors ${
                                activeFilter === pill
                                    ? "bg-primary text-primary-foreground"
                                    : "bg-muted text-muted-foreground"
                            }`}
                        >
                            {pill}
                        </button>
                    ))}
                </div>

                {isLoading && (
                    <div className="flex justify-center py-16">
                        <p className="text-sm text-muted-foreground">Loading events...</p>
                    </div>
                )}

                {isError && (
                    <div className="flex justify-center py-16">
                        <p className="text-sm text-destructive">Failed to load events</p>
                    </div>
                )}

                {!isLoading && !isError && (
                    <div className="mx-auto max-w-[1500px]">
                        <div className="grid grid-cols-1 gap-5 px-4 pb-10 xl:grid-cols-[minmax(0,1fr)_300px]">
                            <div className="space-y-4">
                                {filteredEvents.length === 0 && (
                                    <div className="flex justify-center py-16">
                                        <p className="text-sm text-muted-foreground">No events found</p>
                                    </div>
                                )}
                                {filteredEvents.map((event) => (
                                    <div key={event.id} className="rounded-2xl border border-border bg-card p-3 shadow-sm">
                                        <div className="flex items-center justify-between">
                                            <div className="flex items-center gap-2.5">
                                                <Avatar>
                                                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                                        {getInitials(event.church?.name || event.title)}
                                                    </AvatarFallback>
                                                </Avatar>
                                                <div>
                                                    <p className="text-sm font-semibold">{event.title}</p>
                                                    <p className="text-xs text-muted-foreground">{formatEventDate(event)}</p>
                                                </div>
                                            </div>
                                            <Button variant="ghost" size="icon-sm"><DotsHorizontal size={18} /></Button>
                                        </div>

                                        <p className="mt-2 text-sm leading-relaxed">{event.description}</p>

                                        {event.location && (
                                            <p className="mt-1 text-xs text-muted-foreground">📍 {event.location}</p>
                                        )}

                                        <div className="mt-3 h-40 rounded-xl bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center">
                                            <div className="flex flex-col items-center gap-1 text-muted-foreground">
                                                <Calendar size={24} />
                                                <span className="text-xs font-medium">{formatEventDate(event)}</span>
                                            </div>
                                        </div>

                                        <div className="mt-3 flex items-center justify-between">
                                            <div className="flex items-center gap-4">
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                    <Heart size={18} /><span>{abbreviate(event.attendeeCount)}</span>
                                                </button>
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                    <MessageSquare size={18} /><span>0</span>
                                                </button>
                                                <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                    <Eye size={18} /><span>0</span>
                                                </button>
                                            </div>
                                            <div className="flex items-center gap-3">
                                                <button className="text-muted-foreground"><Bookmark size={18} /></button>
                                                <button className="text-muted-foreground"><CornerUpRight size={18} /></button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                            <EventsRightPanel events={allEvents} />
                        </div>
                    </div>
                )}
            </div>

            {user?.role === "Church Owner" && (
                <Link href="/account/create-post"
                    className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                    <CirclePlus size={28} />
                </Link>
            )}
        </div>
    )
}

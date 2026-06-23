"use client"

import { useState } from "react"
import Link from "next/link"
import { ChevronLeft, Calendar } from "lucide-react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { useAuthStore } from "@/lib/store/auth"
import {
    Heart, Bookmark, Eye, MessageSquare, CornerUpRight, Sparkles,
} from "nasicon-react/outline"
import { DotsHorizontal, CirclePlus } from "nasicon-react/solid"

const filterPills = ["All", "Upcoming", "Past", "Live"]

const events = [
    {
        id: 1,
        name: "Sunday Morning Service",
        organizer: "Beza International",
        initials: "BI",
        date: "Jun 22, 2026",
        time: "9:00 AM",
        description: "Join us for a powerful Sunday service as we worship together and hear the word of God. All are welcome!",
        tags: ["#Worship", "#SundayService"],
        attendees: "1.2k",
        comments: "89",
        views: "4.5k",
        category: "Upcoming",
    },
    {
        id: 2,
        name: "Youth Conference 2026",
        organizer: "Grace Community",
        initials: "GC",
        date: "Jul 5, 2026",
        time: "10:00 AM",
        description: "An empowering three-day youth conference featuring live worship, inspiring speakers, and community outreach programs.",
        tags: ["#Youth", "#Conference"],
        attendees: "3.4k",
        comments: "245",
        views: "12k",
        category: "Upcoming",
    },
    {
        id: 3,
        name: "Prayer Night",
        organizer: "Faith Assembly",
        initials: "FA",
        date: "Jun 18, 2026",
        time: "7:00 PM",
        description: "A night of intercessory prayer and worship. Come with your prayer requests as we seek God together.",
        tags: ["#Prayer", "#NightWatch"],
        attendees: "856",
        comments: "67",
        views: "2.1k",
        category: "Past",
    },
    {
        id: 4,
        name: "Bible Study: Book of Romans",
        organizer: "Beza International",
        initials: "BI",
        date: "Jun 19, 2026",
        time: "6:30 PM",
        description: "Live Bible study streaming now! Join Pastor Samuel as we dive deep into the Book of Romans.",
        tags: ["#BibleStudy", "#Romans"],
        attendees: "2.1k",
        comments: "156",
        views: "6.8k",
        category: "Live",
    },
]

/* ── Right Panel ── */

function EventsRightPanel({ events: evts }: { events: typeof events }) {
    const totalEvents = evts.length
    const upcoming = evts.filter((e) => e.category === "Upcoming").length
    const past = evts.filter((e) => e.category === "Past").length
    const live = evts.filter((e) => e.category === "Live").length
    const categoryLabels = ["All", "Upcoming", "Past", "Live"]

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
                            <p className="text-lg font-black">{live}</p>
                            <p className="text-[11px] text-primary-foreground/70">live</p>
                        </div>
                        <div>
                            <p className="text-lg font-black">{past}</p>
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
                    {evts.filter((e) => e.category === "Upcoming").slice(0, 3).map((e) => (
                        <div key={e.id} className="rounded-xl border border-border bg-background p-2.5">
                            <div className="flex items-center gap-2.5">
                                <Avatar className="size-8">
                                    <AvatarFallback className="bg-primary/20 text-primary text-[10px] font-bold">
                                        {e.initials}
                                    </AvatarFallback>
                                </Avatar>
                                <div className="flex-1 min-w-0">
                                    <p className="text-xs font-semibold truncate">{e.name}</p>
                                    <p className="text-[11px] text-muted-foreground">{e.date}</p>
                                </div>
                            </div>
                        </div>
                    ))}
                    {evts.filter((e) => e.category === "Upcoming").length === 0 && (
                        <p className="text-[11px] text-muted-foreground text-center py-3">No upcoming events</p>
                    )}
                </div>
            </div>
        </aside>
    )
}

/* ── Main Page ── */

export default function EventsPage() {
    const { user } = useAuthStore()
    const [activeFilter, setActiveFilter] = useState("All")

    const filteredEvents = activeFilter === "All" ? events : events.filter((e) => e.category === activeFilter)

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

                <div className="mx-auto max-w-[1500px]">
                    <div className="grid grid-cols-1 gap-5 px-4 pb-10 xl:grid-cols-[minmax(0,1fr)_300px]">
                        <div className="space-y-4">
                            {filteredEvents.map((event) => (
                                <div key={event.id} className="rounded-2xl border border-border bg-card p-3 shadow-sm">
                                    <div className="flex items-center justify-between">
                                        <div className="flex items-center gap-2.5">
                                            <Avatar>
                                                <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                                    {event.initials}
                                                </AvatarFallback>
                                            </Avatar>
                                            <div>
                                                <p className="text-sm font-semibold">{event.name}</p>
                                                <p className="text-xs text-muted-foreground">{event.date} at {event.time}</p>
                                            </div>
                                        </div>
                                        <Button variant="ghost" size="icon-sm"><DotsHorizontal size={18} /></Button>
                                    </div>

                                    <p className="mt-2 text-sm leading-relaxed">{event.description}</p>

                                    <div className="mt-1.5 flex flex-wrap gap-1.5">
                                        {event.tags.map((tag) => (
                                            <Badge key={tag} variant="outline" className="rounded-full text-primary border-primary/30 text-[11px]">
                                                {tag}
                                            </Badge>
                                        ))}
                                    </div>

                                    <div className="mt-3 h-40 rounded-xl bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center">
                                        <div className="flex flex-col items-center gap-1 text-muted-foreground">
                                            <Calendar size={24} />
                                            <span className="text-xs font-medium">{event.date}</span>
                                            <span className="text-[10px]">{event.time}</span>
                                        </div>
                                    </div>

                                    <div className="mt-3 flex items-center justify-between">
                                        <div className="flex items-center gap-4">
                                            <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                <Heart size={18} /><span>{event.attendees}</span>
                                            </button>
                                            <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                <MessageSquare size={18} /><span>{event.comments}</span>
                                            </button>
                                            <button className="flex items-center gap-1 text-sm text-muted-foreground">
                                                <Eye size={18} /><span>{event.views}</span>
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
                        <EventsRightPanel events={filteredEvents} />
                    </div>
                </div>
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

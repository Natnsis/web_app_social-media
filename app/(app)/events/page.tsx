"use client"

import { useState } from "react"
import Link from "next/link"
import { ChevronLeft, Calendar } from "lucide-react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { useAuthStore } from "@/lib/store/auth"
import {
    Heart, Bookmark, Eye, MessageSquare, CornerUpRight,
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

                <div className="px-4 space-y-4 pb-4">
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

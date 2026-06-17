"use client"

import { useState } from "react"
import Link from "next/link"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { ThemeToggle } from "@/components/theme-toggle"
import { useAuthStore } from "@/lib/store/auth"
import { GridCircle, Bell, DotsHorizontal } from "nasicon-react/solid"
import {
    Heart, MessageSquare, Bookmark, CornerUpRight, CirclePlus, Eye,
    HouseChimneyBlank, User, Gift, Users, Globe, ChevronRight,
    Xmark, ArrowRightFromBracket, Church,
    TowerBroadcast, Video, PenSquare, CalendarAlt, LocationPin,
} from "nasicon-react/outline"

const liveUsers = [
    { name: "Grace Ch...", initials: "GC", id: "grace-ch" },
    { name: "Hope Val...", initials: "HV", id: "hope-val" },
    { name: "Unity", initials: "UN", id: "unity" },
    { name: "The Well", initials: "TW", id: "the-well" },
    { name: "New Life", initials: "NL", id: "new-life" },
    { name: "Zion", initials: "ZN", id: "zion" },
]

const posts = [
    {
        id: 1, author: "Grace Community", initials: "GC", time: "2 hours ago",
        text: "What a beautiful Sunday service! The choir\u2019s rendition of \u201cAmazing Grace\u201d brought tears to my eyes. Grateful for this community. \uD83D\uDE4F\u2728",
        hashtags: ["#FaithWalk", "#Community"],
        likes: "1.2k", comments: "48", views: "3.4k",
    },
    {
        id: 2, author: "Grace Community", initials: "GC", time: "2 hours ago",
        text: "Recording a worship cover tonight with the team. Guitar, vocals, and lots of prayer. Can\u2019t wait to share! \uD83C\uDFB8\uD83D\uDE4C\uD83D\uDE4C",
        hashtags: ["#Worship", "#BezaTeam"],
        likes: "856", comments: "12", views: "2k",
        hasVideo: true,
    },
    {
        id: 3, author: "Pastor Marcus", initials: "PM", time: "3 hours ago",
        text: "May your week be filled with the goodness of the Holy Spirit. Remember that no challenge is too great when we walk in faith. Let us continue to support one another in prayer and fellowship.",
        hashtags: ["#Faith", "#Prayer"],
        likes: "2.1k", comments: "84", views: "6.2k",
    },
]

const fabItems = [
    { label: "Create Group", Icon: Users, href: "/chats/new-group" },
    { label: "Create Campaign", Icon: TowerBroadcast, href: "/" },
    { label: "Start Live", Icon: Video, href: "/" },
    { label: "Create Post", Icon: PenSquare, href: "/account/create-post" },
]

const upcomingEvents = [
    { date: "NOV 12", title: "Bible Study", time: "21:00 – 9:30 PM" },
    { date: "NOV 14", title: "Youth Night", time: "11:00 – 3:00 PM" },
]

const nearbyChurches = [
    { name: "Beza Community Church", dist: "0.4 km", initials: "BC" },
    { name: "Summit Fellowship", dist: "1.3 km", initials: "SF" },
]

type MenuSection = {
    title: string
    items: { label: string; icon: React.ReactNode; active?: boolean; extra?: string }[]
}

function SideDrawer({ open, onClose }: { open: boolean; onClose: () => void }) {
    const { user, logout } = useAuthStore()
    const router = useRouter()
    const sections: MenuSection[] = [
        {
            title: "DISCOVER",
            items: [
                { label: "Home", icon: <HouseChimneyBlank size={18} />, active: true },
                { label: "Account Overview", icon: <User size={18} /> },
                { label: "Discovery", icon: <Globe size={18} /> },
            ],
        },
        {
            title: "COMMUNITY",
            items: [
                { label: "Groups", icon: <Users size={18} /> },
                { label: "Campaign", icon: <Church size={18} /> },
                { label: "Gift", icon: <Gift size={18} /> },
            ],
        },
        {
            title: "PREFERENCES",
            items: [{ label: "Language", icon: <Globe size={18} />, extra: "English" }],
        },
    ]

    return (
        <>
            {open && <div className="absolute inset-0 z-40 bg-black/40" onClick={onClose} />}
            <div className={`absolute inset-y-0 left-0 z-50 flex w-72 flex-col bg-background shadow-xl transition-transform duration-300 ${open ? "translate-x-0" : "-translate-x-full"}`}>
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
                    {sections.map((section) => (
                        <div key={section.title}>
                            <p className="mb-1 px-1 text-[10px] font-bold tracking-widest text-muted-foreground">{section.title}</p>
                            {section.items.map((item) => (
                                <button key={item.label}
                                    className={`flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm transition-colors ${item.active ? "bg-primary/10 font-semibold text-primary" : "hover:bg-muted"}`}>
                                    <span className={item.active ? "text-primary" : "text-muted-foreground"}>{item.icon}</span>
                                    <span className="flex-1 text-left">{item.label}</span>
                                    {item.extra && <><span className="text-xs text-muted-foreground">{item.extra}</span><ChevronRight size={14} className="text-muted-foreground" /></>}
                                </button>
                            ))}
                        </div>
                    ))}
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

/* ── Shared feed content (used on both mobile and desktop) ── */
function FeedContent() {
    return (
        <div className="space-y-4">
            {/* Daily Verse */}
            <div className="overflow-hidden rounded-2xl">
                <div className="relative min-h-[150px] bg-cover bg-center px-4 py-5" style={{ backgroundImage: "url('/background.jpg')" }}>
                    <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-black/70 to-blue-900/60" />
                    <div className="relative z-10 space-y-2">
                        <p className="text-[10px] font-semibold tracking-widest text-blue-300 uppercase">Daily Scripture</p>
                        <p className="text-xl font-bold leading-snug text-white">
                            &ldquo;The Lord is my light and my salvation&mdash;whom shall I fear?&rdquo;
                        </p>
                        <p className="text-sm font-semibold text-blue-300">Psalm 27:1</p>
                    </div>
                </div>
            </div>

            {/* Live Now */}
            <div>
                <div className="mb-2.5 flex items-center justify-between">
                    <h2 className="text-sm font-bold text-primary">Live Now</h2>
                    <Button variant="outline" size="xs" className="rounded-full border-primary/50 text-primary text-[10px]">See all</Button>
                </div>
                <div className="flex h-fit gap-4 overflow-x-auto px-1 py-1">
                    {liveUsers.map((u, i) => (
                        <Link key={i} href={`/live/${u.id}`} className="relative flex shrink-0 flex-col items-center gap-1">
                            <div className="relative">
                                <Avatar className="size-14 ring-2 ring-red-500 ring-offset-1">
                                    <AvatarFallback className="bg-muted text-xs font-medium">{u.initials}</AvatarFallback>
                                </Avatar>
                                <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 flex items-center gap-0.5 rounded-full bg-red-500 px-1.5 py-0.5">
                                    <div className="size-1 rounded-full bg-white animate-pulse" />
                                    <span className="text-[8px] font-bold text-white">LIVE</span>
                                </div>
                            </div>
                            <span className="mt-2 w-14 truncate text-center text-[10px] text-muted-foreground">{u.name}</span>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Posts */}
            <div className="space-y-4">
                {posts.map((post) => (
                    <div key={post.id} className="rounded-2xl border border-border bg-card p-4 shadow-sm transition-shadow hover:shadow-md">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2.5">
                                <Avatar>
                                    <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">{post.initials}</AvatarFallback>
                                </Avatar>
                                <div>
                                    <p className="text-sm font-semibold">{post.author}</p>
                                    <p className="text-xs text-muted-foreground">{post.time}</p>
                                </div>
                            </div>
                            <Button variant="ghost" size="icon-sm"><DotsHorizontal size={20} /></Button>
                        </div>
                        <p className="mt-2 text-sm leading-relaxed">{post.text}</p>
                        <div className="mt-1.5 flex flex-wrap gap-1.5">
                            {post.hashtags.map((tag) => (
                                <Badge key={tag} variant="outline" className="rounded-full text-primary border-primary/30 text-[11px]">{tag}</Badge>
                            ))}
                        </div>
                        {post.hasVideo
                            ? <div className="mt-3 h-48 rounded-xl bg-gray-300 dark:bg-gray-700 flex items-center justify-center"><div className="flex size-14 items-center justify-center rounded-full bg-primary/80"><span className="text-white text-2xl">▶</span></div></div>
                            : <div className="mt-3 h-44 rounded-xl bg-gray-200 dark:bg-gray-700" />
                        }
                        <div className="mt-3 flex items-center justify-between">
                            <div className="flex items-center gap-4">
                                <button className="flex items-center gap-1 text-sm text-muted-foreground hover:text-red-500 transition-colors"><Heart size={17} /><span>{post.likes}</span></button>
                                <button className="flex items-center gap-1 text-sm text-muted-foreground hover:text-primary transition-colors"><MessageSquare size={17} /><span>{post.comments}</span></button>
                                <button className="flex items-center gap-1 text-sm text-muted-foreground"><Eye size={17} /><span>{post.views}</span></button>
                            </div>
                            <div className="flex items-center gap-3">
                                <button className="text-muted-foreground hover:text-primary transition-colors"><Bookmark size={17} /></button>
                                <button className="text-muted-foreground hover:text-primary transition-colors"><CornerUpRight size={17} /></button>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    )
}

/* ── Desktop right panel ── */
function DesktopRightPanel() {
    return (
        <aside className="hidden xl:flex w-72 shrink-0 flex-col h-full overflow-y-auto border-l border-border bg-background/50 px-4 py-5 space-y-6">
            <div>
                <p className="text-xs font-bold tracking-wider text-muted-foreground uppercase mb-1">Contextual Insights</p>
                <p className="text-[11px] text-muted-foreground">Stay updated with your community</p>
            </div>

            {/* Upcoming Events */}
            <div>
                <div className="flex items-center justify-between mb-3">
                    <p className="flex items-center gap-1.5 text-xs font-bold"><CalendarAlt size={13} className="text-primary" /> Upcoming Events</p>
                    <button className="text-[11px] text-primary hover:underline">View All</button>
                </div>
                <div className="space-y-2.5">
                    {upcomingEvents.map((ev) => (
                        <div key={ev.title} className="flex gap-3 rounded-xl border border-border bg-card p-2.5">
                            <div className="flex w-10 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary">
                                <p className="text-[9px] font-bold uppercase leading-tight">{ev.date.split(" ")[0]}</p>
                                <p className="text-base font-bold leading-tight">{ev.date.split(" ")[1]}</p>
                            </div>
                            <div>
                                <p className="text-xs font-semibold">{ev.title}</p>
                                <p className="text-[10px] text-muted-foreground">{ev.time}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <Separator />

            {/* Nearby Churches */}
            <div>
                <p className="flex items-center gap-1.5 text-xs font-bold mb-3"><LocationPin size={13} className="text-primary" /> Nearby Churches</p>
                <div className="space-y-2">
                    {nearbyChurches.map((c) => (
                        <div key={c.name} className="flex items-center gap-2.5 rounded-xl border border-border bg-card p-2.5">
                            <Avatar size="sm">
                                <AvatarFallback className="bg-primary/20 text-primary text-[10px]">{c.initials}</AvatarFallback>
                            </Avatar>
                            <div className="flex-1 min-w-0">
                                <p className="text-xs font-semibold truncate">{c.name}</p>
                                <p className="text-[10px] text-muted-foreground">{c.dist}</p>
                            </div>
                        </div>
                    ))}
                    <Button variant="outline" size="xs" className="w-full rounded-xl text-xs">Open Local Map</Button>
                </div>
            </div>

            <Separator />

            {/* Global Impact */}
            <div>
                <p className="text-xs font-bold mb-3">🌍 Global Impact</p>
                <div className="rounded-xl border border-border bg-card p-3 space-y-2">
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Active Missions</span>
                        <span className="font-semibold text-primary">12</span>
                    </div>
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground">Countries</span>
                        <span className="font-semibold">8 Countries</span>
                    </div>
                    <p className="text-[10px] text-muted-foreground leading-relaxed">
                        Your support currently funds 12 active mission outposts across Eastern Africa and Southern Asia.
                    </p>
                </div>
            </div>
        </aside>
    )
}

export default function HomePage() {
    const { user } = useAuthStore()
    const [drawerOpen, setDrawerOpen] = useState(false)
    const [fabOpen, setFabOpen] = useState(false)

    return (
        <>
            {/* ── Desktop layout (lg+): full-width with right panel ── */}
            <div className="hidden lg:flex h-full overflow-hidden">
                <div className="flex-1 overflow-y-auto px-3 md:px-5 py-5">
                    <div className="mx-auto max-w-3xl">
                        <FeedContent />
                    </div>
                </div>
                <DesktopRightPanel />
            </div>

            {/* ── Mobile layout (< lg): phone-style ── */}
            <div className="lg:hidden relative flex h-full flex-col overflow-hidden">
                <SideDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)} />

                {fabOpen && (
                    <div className="absolute inset-0 z-20 bg-black/40 backdrop-blur-sm" onClick={() => setFabOpen(false)} />
                )}

                <header className="flex shrink-0 items-center justify-between px-3 py-2 md:px-5 md:py-3">
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

                <div className="flex-1 overflow-y-auto px-3 md:px-5">
                    <FeedContent />
                    <div className="pb-24" />
                </div>

                {/* FAB speed-dial — Church Owner only */}
                {user?.role === "Church Owner" && (
                    <div className="absolute bottom-4 right-4 z-30 flex flex-col-reverse items-end gap-3">
                        {fabOpen && fabItems.map((item, i) => (
                            <Link key={i} href={item.href} onClick={() => setFabOpen(false)}
                                className="flex items-center gap-3 animate-in slide-in-from-bottom-2 fade-in-0"
                                style={{ animationDelay: `${i * 40}ms` }}>
                                <span className="rounded-xl bg-background px-3 py-1.5 text-sm font-semibold shadow-md border border-border">{item.label}</span>
                                <div className="flex size-11 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
                                    <item.Icon size={20} />
                                </div>
                            </Link>
                        ))}
                        <button
                            onClick={() => setFabOpen((v) => !v)}
                            className="flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg transition-transform duration-200"
                            style={{ transform: fabOpen ? "rotate(45deg)" : "rotate(0deg)" }}>
                            {fabOpen ? <Xmark size={24} /> : <CirclePlus size={28} />}
                        </button>
                    </div>
                )}
            </div>
        </>
    )
}

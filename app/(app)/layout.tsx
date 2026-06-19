"use client"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ThemeToggle } from "@/components/theme-toggle"
import { Calendar } from "lucide-react"
import {
    HouseChimneyBlank, Annotation, CirclePlay, User,
    Gear, Bell, Search, Heart, PenSquare, ArrowRightFromBracket,
    ChartBar, Church, GridCircle,
} from "nasicon-react/outline"
import {
    HouseChimneyBlank as HouseChimneyBlankSolid,
    Annotation as AnnotationSolid,
    CirclePlay as CirclePlaySolid,
    User as UserSolid,
    Heart as HeartSolid,
} from "nasicon-react/solid"

const mobileNavItems = [
    { href: "/", label: "Home", Icon: HouseChimneyBlank, ActiveIcon: HouseChimneyBlankSolid },
    { href: "/chats", label: "Chats", Icon: Annotation, ActiveIcon: AnnotationSolid },
    { href: "/shorts", label: "Shorts", Icon: CirclePlay, ActiveIcon: CirclePlaySolid },
    { href: "/account", label: "Account", Icon: User, ActiveIcon: UserSolid },
]

interface NavItem {
    href: string
    label: string
    Icon: any
    ActiveIcon: any
    ownerOnly?: boolean
}

interface NavSection {
    title: string
    items: NavItem[]
}

const desktopNavItems: NavSection[] = [
    {
        title: "Community",
        items: [
            { href: "/", label: "Feed", Icon: HouseChimneyBlank, ActiveIcon: HouseChimneyBlankSolid },
            { href: "/shorts", label: "Shorts", Icon: CirclePlay, ActiveIcon: CirclePlaySolid },
            { href: "/chats", label: "Messages", Icon: Annotation, ActiveIcon: AnnotationSolid },
        ],
    },
    {
        title: "Outreach",
        items: [
            { href: "/campaigns", label: "Campaigns", Icon: Heart, ActiveIcon: HeartSolid },
            { href: "/events", label: "Events", Icon: Calendar, ActiveIcon: Calendar, ownerOnly: false },
        ],
    },
    {
        title: "Church",
        items: [
            { href: "/account", label: "Profile", Icon: Church, ActiveIcon: Church },
            { href: "/account/create-post", label: "Content Studio", Icon: PenSquare, ActiveIcon: PenSquare, ownerOnly: true },
            { href: "/account/settings", label: "Settings", Icon: Gear, ActiveIcon: Gear },
        ],
    },
]

function DesktopSidebar({ pathname, collapsed }: { pathname: string; collapsed: boolean }) {
    const { user, logout } = useAuthStore()
    const router = useRouter()

    return (
        <aside className={`hidden h-screen shrink-0 overflow-hidden border-r border-border bg-card transition-[width] duration-300 lg:flex ${collapsed ? "w-20" : "w-64 xl:w-72"}`}>
            <div className="flex h-full w-full flex-col overflow-y-auto">
            {/* Brand */}
            <div className={`border-b border-border py-5 ${collapsed ? "px-3" : "px-5"}`}>
                <div className={`flex items-center ${collapsed ? "justify-center" : "gap-2"}`}>
                    <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z" />
                            <path d="M2 17l10 5 10-5" />
                            <path d="M2 12l10 5 10-5" />
                        </svg>
                    </div>
                    <div className={`min-w-0 transition-opacity duration-200 ${collapsed ? "hidden" : "block"}`}>
                        <p className="truncate text-base font-black leading-tight">Faith<span className="text-primary">Connect</span></p>
                        <p className="truncate text-xs text-muted-foreground">{user?.org ?? "Beza International"}</p>
                    </div>
                </div>
            </div>

            {/* Nav */}
            <nav className={`flex-1 space-y-5 py-4 ${collapsed ? "px-3" : "px-3"}`}>
                {desktopNavItems.map((section) => (
                    <div key={section.title}>
                        {!collapsed && <p className="mb-2 px-3 text-[10px] font-black uppercase tracking-[0.18em] text-muted-foreground">{section.title}</p>}
                        <div className="space-y-1">
                            {section.items.filter((item) => !item.ownerOnly || user?.role === "Church Owner").map(({ href, label, Icon, ActiveIcon }) => {
                                const isActive = href === "/" ? pathname === "/" : pathname.startsWith(href)
                                const IconComp = isActive ? ActiveIcon : Icon
                                return (
                                    <Link key={label} href={href}
                                        title={collapsed ? label : undefined}
                                        className={`relative flex items-center rounded-xl text-sm font-semibold transition-colors ${collapsed ? "justify-center px-0 py-3" : "gap-3 px-3 py-2.5"} ${isActive
                                            ? "bg-primary/10 text-primary"
                                            : "text-muted-foreground hover:bg-muted hover:text-foreground"
                                            }`}>
                                        {isActive && <span className="absolute left-0 top-1/2 h-5 w-1 -translate-y-1/2 rounded-r bg-primary" />}
                                        <IconComp size={18} />
                                        {!collapsed && <span>{label}</span>}
                                    </Link>
                                )
                            })}
                        </div>
                    </div>
                ))}
            </nav>

            {/* Give Now CTA */}
            <div className={`pb-4 ${collapsed ? "px-3" : "px-4"}`}>
                <div className="rounded-xl border border-border bg-background p-3">
                    <div className={`flex items-center gap-2 ${collapsed ? "justify-center" : "justify-between"}`}>
                        <div className={collapsed ? "hidden" : "block"}>
                            <p className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Giving</p>
                            <p className="mt-1 text-lg font-black">$18.2k</p>
                        </div>
                        <ChartBar size={20} className="text-primary" />
                    </div>
                    <Link href="/campaigns" className={`mt-3 w-full rounded-xl ${collapsed ? "px-0" : "gap-2"} inline-flex items-center justify-center text-sm font-medium transition-colors bg-primary text-primary-foreground hover:bg-primary/90 h-9 px-4 py-2`} aria-label="Give Now">
                        <Heart size={14} />
                        {!collapsed && "Give Now"}
                    </Link>
                </div>
            </div>

            {/* Footer links */}
            <div className={`space-y-1 border-t border-border/70 py-4 ${collapsed ? "px-3" : "px-5"}`}>
                <div className={`mb-3 flex items-center rounded-xl bg-muted py-2 ${collapsed ? "justify-center px-2" : "gap-2 px-3"}`}>
                    <Avatar className="size-8">
                        <AvatarFallback className="bg-primary text-primary-foreground text-[11px] font-bold">{user?.initials ?? "AT"}</AvatarFallback>
                    </Avatar>
                    <div className={`min-w-0 ${collapsed ? "hidden" : "block"}`}>
                        <p className="truncate text-xs font-bold">{user?.name ?? "Church Admin"}</p>
                        <p className="truncate text-[10px] text-muted-foreground">{user?.role ?? "Member"}</p>
                    </div>
                </div>
                <button className={`flex w-full items-center py-1 text-xs text-muted-foreground hover:text-foreground ${collapsed ? "justify-center" : "gap-2"}`} title={collapsed ? "Support" : undefined}>
                    <Gear size={13} /> {!collapsed && "Support"}
                </button>
                <button
                    onClick={() => { logout(); router.push("/login") }}
                    className={`flex w-full items-center py-1 text-xs text-muted-foreground hover:text-destructive ${collapsed ? "justify-center" : "gap-2"}`}
                    title={collapsed ? "Logout" : undefined}>
                    <ArrowRightFromBracket size={13} /> {!collapsed && "Logout"}
                </button>
            </div>
            </div>
        </aside>
    )
}

function DesktopTopbar({ collapsed, onToggleSidebar }: { collapsed: boolean; onToggleSidebar: () => void }) {
    const { user } = useAuthStore()
    return (
        <header className="sticky top-0 z-10 hidden shrink-0 items-center gap-3 border-b border-border bg-background px-5 py-3 lg:flex">
            <Button
                variant="outline"
                size="icon-lg"
                className="rounded-xl bg-card"
                onClick={onToggleSidebar}
                aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"}
            >
                <GridCircle size={18} />
            </Button>
            <div className="max-w-xl flex-1">
                <div className="relative">
                    <Search size={17} className="absolute left-4 top-1/2 -translate-y-1/2 text-muted-foreground" />
                    <Input placeholder="Search sermons, events, groups, or ministries..." className="h-10 rounded-xl border-border bg-card pl-11 pr-4 text-sm" />
                </div>
            </div>
            <div className="ml-auto flex items-center gap-2">
                <ThemeToggle />
                <Button variant="outline" size="icon-lg" className="relative rounded-xl bg-card">
                    <Bell size={18} />
                    <span className="absolute right-2 top-2 size-2 rounded-full bg-red-500 ring-2 ring-background" />
                </Button>
                <Avatar className="size-10 cursor-pointer border border-border">
                    <AvatarFallback className="bg-primary text-primary-foreground text-sm font-bold">{user?.initials ?? "AT"}</AvatarFallback>
                </Avatar>
            </div>
        </header>
    )
}

export default function AppLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname()
    const router = useRouter()
    const [hydrated, setHydrated] = useState(false)
    const [sidebarCollapsed, setSidebarCollapsed] = useState(false)

    useEffect(() => {
        const rehydrate = async () => {
            await useAuthStore.persist.rehydrate()
            setHydrated(true)
            const state = useAuthStore.getState()
            if (!state.isAuthenticated) {
                router.replace("/login")
            } else if (state.accessToken) {
                try {
                    const base64Url = state.accessToken.split(".")[1]
                    if (base64Url) {
                        const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/")
                        const jsonPayload = decodeURIComponent(
                            atob(base64)
                                .split("")
                                .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
                                .join("")
                        )
                        console.log("AUTHORIZED USER DECODED TOKEN:", JSON.parse(jsonPayload))
                    }
                } catch (e) {
                    console.error("Failed to decode token on layout mount", e)
                }
            }
        }
        rehydrate()
    }, [router])

    if (!hydrated) {
        return (
            <div className="flex h-screen items-center justify-center bg-background">
                <div className="size-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
        )
    }

    return (
        <div className="min-h-screen bg-background">
            {/* ── Desktop (lg+): sidebar layout ── */}
            <div className="hidden h-screen overflow-hidden lg:flex">
                <DesktopSidebar pathname={pathname} collapsed={sidebarCollapsed} />
                <div className="flex flex-1 flex-col overflow-hidden">
                    <DesktopTopbar collapsed={sidebarCollapsed} onToggleSidebar={() => setSidebarCollapsed((value) => !value)} />
                    <main className="flex-1 overflow-hidden">
                        {children}
                    </main>
                </div>
            </div>

            {/* ── Mobile / Tablet (< lg): always full-screen, edge-to-edge ── */}
            <div className="lg:hidden flex h-screen w-full overflow-hidden bg-background">
                <div className="relative flex h-full w-full max-w-2xl mx-auto flex-col overflow-hidden bg-background">
                    <div className="flex-1 overflow-hidden">{children}</div>

                    <nav className="flex shrink-0 items-center justify-around border-t border-border bg-background px-2 py-2">
                        {mobileNavItems.map(({ href, label, Icon, ActiveIcon }) => {
                            const isActive = href === "/" ? pathname === "/" : pathname.startsWith(href)
                            const IconComp = isActive ? ActiveIcon : Icon
                            return (
                                <Link key={href} href={href}
                                    className={`flex flex-col items-center gap-0.5 px-3 py-1 text-xs font-medium transition-colors sm:px-5 md:px-8 ${isActive ? "text-primary" : "text-muted-foreground"}`}>
                                    <IconComp size={22} />
                                    <span>{label}</span>
                                </Link>
                            )
                        })}
                    </nav>
                </div>
            </div>
        </div>
    )
}

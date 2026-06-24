"use client"

import { useEffect, useState, type CSSProperties } from "react"
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
    Church, GridCircle,
} from "nasicon-react/outline"
import {
    HouseChimneyBlank as HouseChimneyBlankSolid,
    Annotation as AnnotationSolid,
    CirclePlay as CirclePlaySolid,
    User as UserSolid,
    Heart as HeartSolid,
} from "nasicon-react/solid"
import {
    SidebarProvider,
    SidebarContent,
    SidebarGroup,
    SidebarGroupContent,
    SidebarGroupLabel,
    SidebarHeader,
    SidebarFooter,
    SidebarMenu,
    SidebarMenuItem,
    SidebarMenuButton,
    SidebarSeparator,
    useSidebar,
} from "@/components/ui/sidebar"

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

function DesktopSidebar() {
    const { user, logout } = useAuthStore()
    const router = useRouter()
    const pathname = usePathname()
    const { state } = useSidebar()
    const collapsed = state === "collapsed"

    return (
        <aside className={`hidden h-screen shrink-0 overflow-hidden border-r border-border bg-sidebar text-sidebar-foreground transition-[width] duration-200 lg:flex ${collapsed ? "w-20" : "w-64 xl:w-72"}`}>
            <div className="flex h-full w-full flex-col">
                <SidebarHeader>
                    <div className={`flex items-center ${collapsed ? "justify-center px-2" : "gap-2 px-4"} py-2`}>
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
                </SidebarHeader>
                <SidebarContent>
                    {desktopNavItems.map((section) => (
                        <SidebarGroup key={section.title}>
                            {!collapsed && <SidebarGroupLabel>{section.title}</SidebarGroupLabel>}
                            <SidebarGroupContent>
                                <SidebarMenu>
                                    {section.items.filter((item) => !item.ownerOnly || user?.role === "Church Owner").map(({ href, label, Icon, ActiveIcon }) => {
                                        const isActive = href === "/" ? pathname === "/" : pathname.startsWith(href)
                                        const IconComp = isActive ? ActiveIcon : Icon
                                        return (
                                            <SidebarMenuItem key={label}>
                                                {isActive && (
                                                    <span className="absolute left-0 top-1/2 z-10 h-5 w-1 -translate-y-1/2 rounded-r bg-primary" />
                                                )}
                                                <SidebarMenuButton
                                                    isActive={isActive}
                                                    tooltip={collapsed ? label : undefined}
                                                    render={<Link href={href} />}
                                                >
                                                    <IconComp size={18} />
                                                    {!collapsed && <span>{label}</span>}
                                                </SidebarMenuButton>
                                            </SidebarMenuItem>
                                        )
                                    })}
                                </SidebarMenu>
                            </SidebarGroupContent>
                        </SidebarGroup>
                    ))}
                </SidebarContent>
                <SidebarFooter>
                    <div className={`mb-3 flex items-center rounded-xl bg-muted py-2 ${collapsed ? "justify-center px-2" : "gap-2 px-3"}`}>
                        <Avatar className="size-8">
                            <AvatarFallback className="bg-primary text-primary-foreground text-[11px] font-bold">{user?.initials ?? "AT"}</AvatarFallback>
                        </Avatar>
                        <div className={`min-w-0 ${collapsed ? "hidden" : "block"}`}>
                            <p className="truncate text-xs font-bold">{user?.name ?? "Church Admin"}</p>
                            <p className="truncate text-[10px] text-muted-foreground">{user?.role ?? "Member"}</p>
                        </div>
                    </div>
                    <div className={`space-y-1 ${collapsed ? "px-2" : "px-3"}`}>
                        <button className={`flex w-full items-center py-1 text-xs text-muted-foreground hover:text-foreground ${collapsed ? "justify-center" : "gap-2"}`}>
                            <Gear size={13} />
                            {!collapsed && "Support"}
                        </button>
                        <button
                            onClick={() => { logout(); router.push("/login") }}
                            className={`flex w-full items-center py-1 text-xs text-muted-foreground hover:text-destructive ${collapsed ? "justify-center" : "gap-2"}`}
                        >
                            <ArrowRightFromBracket size={13} />
                            {!collapsed && "Logout"}
                        </button>
                    </div>
                </SidebarFooter>
            </div>
        </aside>
    )
}

function DesktopTopbar() {
    const { user } = useAuthStore()
    const { toggleSidebar, state } = useSidebar()
    const collapsed = state === "collapsed"

    return (
        <header className="sticky top-0 z-10 hidden shrink-0 items-center gap-3 border-b border-border bg-background px-5 py-3 lg:flex">
            <Button
                variant="outline"
                size="icon-lg"
                className="rounded-xl bg-card"
                onClick={toggleSidebar}
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
        <SidebarProvider defaultOpen style={{ display: "contents" } as CSSProperties}>
            <div className="min-h-screen bg-background">
                {/* ── Desktop (lg+): sidebar layout ── */}
                <div className="hidden h-screen overflow-hidden lg:flex">
                    <DesktopSidebar />
                    <div className="flex flex-1 flex-col overflow-hidden">
                        <DesktopTopbar />
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
        </SidebarProvider>
    )
}

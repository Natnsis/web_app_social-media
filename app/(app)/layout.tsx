"use client"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { ThemeToggle } from "@/components/theme-toggle"
import {
    HouseChimneyBlank, Annotation, CirclePlay, User,
    Gear, Bell, Search, Heart, PenSquare, ArrowRightFromBracket,
} from "nasicon-react/outline"
import {
    HouseChimneyBlank as HouseChimneyBlankSolid,
    Annotation as AnnotationSolid,
    CirclePlay as CirclePlaySolid,
    User as UserSolid,
} from "nasicon-react/solid"

const mobileNavItems = [
    { href: "/", label: "Home", Icon: HouseChimneyBlank, ActiveIcon: HouseChimneyBlankSolid },
    { href: "/chats", label: "Chats", Icon: Annotation, ActiveIcon: AnnotationSolid },
    { href: "/shorts", label: "Shorts", Icon: CirclePlay, ActiveIcon: CirclePlaySolid },
    { href: "/account", label: "Account", Icon: User, ActiveIcon: UserSolid },
]

const desktopNavItems = [
    { href: "/", label: "Home", Icon: HouseChimneyBlank, ActiveIcon: HouseChimneyBlankSolid },
    { href: "/chats", label: "Chats", Icon: Annotation, ActiveIcon: AnnotationSolid },
    { href: "/shorts", label: "Shorts", Icon: CirclePlay, ActiveIcon: CirclePlaySolid },
    { href: "/account", label: "Account", Icon: User, ActiveIcon: UserSolid },
    { href: "/account/settings", label: "Settings", Icon: Gear, ActiveIcon: Gear },
]

function DesktopSidebar({ pathname }: { pathname: string }) {
    const { user, logout } = useAuthStore()
    const router = useRouter()

    return (
        <aside className="hidden lg:flex lg:w-56 xl:w-64 shrink-0 flex-col h-screen sticky top-0 border-r border-border bg-background/95 backdrop-blur-sm overflow-y-auto">
            {/* Brand */}
            <div className="px-4 py-5 border-b border-border">
                <div className="flex items-center gap-2">
                    <div className="flex size-8 items-center justify-center rounded-lg bg-primary shrink-0">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z" />
                            <path d="M2 17l10 5 10-5" />
                            <path d="M2 12l10 5 10-5" />
                        </svg>
                    </div>
                    <div className="min-w-0">
                        <p className="text-sm font-bold leading-tight truncate">Faith<span className="text-primary">Connect</span></p>
                        <p className="text-[10px] text-muted-foreground truncate">{user?.org ?? "Beza International"}</p>
                    </div>
                </div>
            </div>

            {/* Nav */}
            <nav className="flex-1 px-3 py-4 space-y-0.5">
                {desktopNavItems.map(({ href, label, Icon, ActiveIcon }) => {
                    const isActive = href === "/" ? pathname === "/" : pathname.startsWith(href)
                    const IconComp = isActive ? ActiveIcon : Icon
                    return (
                        <Link key={label} href={href}
                            className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all ${isActive
                                ? "bg-primary/10 text-primary"
                                : "text-muted-foreground hover:bg-muted hover:text-foreground"
                                }`}>
                            <IconComp size={18} />
                            <span>{label}</span>
                        </Link>
                    )
                })}
                {user?.role === "Church Owner" && (
                    <Link href="/account/create-post"
                        className="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-all text-muted-foreground hover:bg-muted hover:text-foreground">
                        <PenSquare size={18} />
                        <span>Create Post</span>
                    </Link>
                )}
            </nav>

            {/* Give Now CTA */}
            <div className="px-3 pb-3">
                <Button className="w-full gap-2 rounded-xl" size="sm">
                    <Heart size={14} />
                    Give Now
                </Button>
            </div>

            {/* Footer links */}
            <div className="border-t border-border px-4 py-3 space-y-1">
                <button className="flex w-full items-center gap-2 text-xs text-muted-foreground hover:text-foreground py-1">
                    <Gear size={13} /> Support
                </button>
                <button
                    onClick={() => { logout(); router.push("/login") }}
                    className="flex w-full items-center gap-2 text-xs text-muted-foreground hover:text-destructive py-1">
                    <ArrowRightFromBracket size={13} /> Logout
                </button>
            </div>
        </aside>
    )
}

function DesktopTopbar() {
    const { user } = useAuthStore()
    return (
        <header className="hidden lg:flex shrink-0 items-center gap-3 border-b border-border bg-background/95 backdrop-blur-sm px-4 py-2.5 sticky top-0 z-10">
            <div className="flex-1 max-w-md">
                <div className="relative">
                    <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
                    <Input placeholder="Search sermons, events, or ministries..." className="pl-9 h-9 rounded-full text-sm" />
                </div>
            </div>
            <div className="flex items-center gap-1 ml-auto">
                <ThemeToggle />
                <Button variant="ghost" size="icon-sm" className="relative">
                    <Bell size={18} />
                    <span className="absolute top-1 right-1 size-1.5 rounded-full bg-red-500" />
                </Button>
                <Avatar size="sm" className="cursor-pointer">
                    <AvatarFallback className="bg-primary text-primary-foreground text-xs">{user?.initials ?? "AT"}</AvatarFallback>
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
        <div className="min-h-screen bg-background">
            {/* ── Desktop (lg+): sidebar layout ── */}
            <div className="hidden lg:flex h-screen overflow-hidden">
                <DesktopSidebar pathname={pathname} />
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
    )
}

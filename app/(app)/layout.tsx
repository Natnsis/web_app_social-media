"use client"

import { useEffect, useState } from "react"
import { useRouter, usePathname } from "next/navigation"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { HouseChimneyBlank, Annotation, CirclePlay, User } from "nasicon-react/outline"
import {
    HouseChimneyBlank as HouseChimneyBlankSolid,
    Annotation as AnnotationSolid,
    CirclePlay as CirclePlaySolid,
    User as UserSolid,
} from "nasicon-react/solid"

const navItems = [
    { href: "/", label: "Home", Icon: HouseChimneyBlank, ActiveIcon: HouseChimneyBlankSolid },
    { href: "/chats", label: "Chats", Icon: Annotation, ActiveIcon: AnnotationSolid },
    { href: "/shorts", label: "Shorts", Icon: CirclePlay, ActiveIcon: CirclePlaySolid },
    { href: "/account", label: "Account", Icon: User, ActiveIcon: UserSolid },
]

export default function AppLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname()
    const router = useRouter()
    const [hydrated, setHydrated] = useState(false)

    useEffect(() => {
        // Wait for Zustand persist to rehydrate from localStorage
        const rehydrate = async () => {
            await useAuthStore.persist.rehydrate()
            setHydrated(true)
            if (!useAuthStore.getState().isAuthenticated) {
                router.replace("/login")
            }
        }
        rehydrate()
    }, [router])

    // While waiting for hydration, show a minimal spinner
    if (!hydrated) {
        return (
            <div className="flex h-screen items-center justify-center bg-background">
                <div className="size-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
        )
    }

    return (
        <div className="mx-auto flex h-screen max-w-sm flex-col overflow-hidden bg-background">
            <div className="flex-1 overflow-hidden">{children}</div>

            <nav className="flex shrink-0 items-center justify-around border-t border-border bg-background px-2 py-2">
                {navItems.map(({ href, label, Icon, ActiveIcon }) => {
                    const isActive = href === "/" ? pathname === "/" : pathname.startsWith(href)
                    const IconComp = isActive ? ActiveIcon : Icon
                    return (
                        <Link
                            key={href}
                            href={href}
                            className={`flex flex-col items-center gap-0.5 px-3 py-1 text-xs font-medium transition-colors ${isActive ? "text-primary" : "text-muted-foreground"
                                }`}
                        >
                            <IconComp size={22} />
                            <span>{label}</span>
                        </Link>
                    )
                })}
            </nav>
        </div>
    )
}

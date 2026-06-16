"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { useAuthStore } from "@/lib/store/auth"

export default function LoginPage() {
    const router = useRouter()
    const login = useAuthStore((s) => s.login)
    const [email, setEmail] = useState("abebe@beza.org")
    const [password, setPassword] = useState("password123")
    const [loading, setLoading] = useState(false)
    const [checking, setChecking] = useState(true)

    useEffect(() => {
        // After hydration, if already logged in skip login screen
        const run = async () => {
            await useAuthStore.persist.rehydrate()
            if (useAuthStore.getState().isAuthenticated) {
                router.replace("/")
            } else {
                setChecking(false)
            }
        }
        run()
    }, [router])

    function handleLogin(e: React.FormEvent) {
        e.preventDefault()
        setLoading(true)
        login(email, password)
        router.replace("/")
    }

    if (checking) {
        return (
            <div className="flex h-screen items-center justify-center bg-background">
                <div className="size-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
        )
    }

    return (
        <div className="flex h-screen flex-col items-center justify-center bg-background px-6">
            <div className="w-full max-w-sm space-y-8">

                {/* Branding */}
                <div className="flex flex-col items-center gap-3">
                    <div className="flex size-16 items-center justify-center rounded-2xl bg-primary">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none"
                            stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z" />
                            <path d="M2 17l10 5 10-5" />
                            <path d="M2 12l10 5 10-5" />
                        </svg>
                    </div>
                    <h1 className="text-3xl font-bold tracking-tight">
                        Faith<span className="text-primary">Connect</span>
                    </h1>
                    <p className="text-center text-sm text-muted-foreground">
                        Connect with your faith community
                    </p>
                </div>

                {/* Form */}
                <form onSubmit={handleLogin} className="space-y-4">
                    <div className="space-y-2">
                        <label htmlFor="email" className="text-sm font-medium">Email</label>
                        <input
                            id="email"
                            type="email"
                            autoComplete="email"
                            placeholder="you@example.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="h-12 w-full rounded-xl border border-border bg-background px-4 text-sm outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                        />
                    </div>

                    <div className="space-y-2">
                        <label htmlFor="password" className="text-sm font-medium">Password</label>
                        <input
                            id="password"
                            type="password"
                            autoComplete="current-password"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="h-12 w-full rounded-xl border border-border bg-background px-4 text-sm outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                        />
                    </div>

                    <div className="flex justify-end">
                        <button type="button" className="text-xs text-primary hover:underline">
                            Forgot password?
                        </button>
                    </div>

                    <Button type="submit" disabled={loading} className="h-12 w-full rounded-xl text-base">
                        {loading ? "Logging in..." : "Log In"}
                    </Button>
                </form>

                <p className="text-center text-sm text-muted-foreground">
                    Don&apos;t have an account?{" "}
                    <button type="button" className="font-medium text-primary hover:underline">
                        Sign up
                    </button>
                </p>
            </div>
        </div>
    )
}

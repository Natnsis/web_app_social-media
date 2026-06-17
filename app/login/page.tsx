"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { useAuthStore } from "@/lib/store/auth"

function BrandLogo() {
    return (
        <div className="flex items-center gap-2">
            <div className="flex size-8 items-center justify-center rounded-lg bg-primary shrink-0">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M12 2L2 7l10 5 10-5-10-5z" />
                    <path d="M2 17l10 5 10-5" />
                    <path d="M2 12l10 5 10-5" />
                </svg>
            </div>
            <span className="text-sm font-bold text-white">Faith<span className="text-blue-300">Connect</span></span>
        </div>
    )
}

export default function LoginPage() {
    const router = useRouter()
    const { login, loginError, clearError } = useAuthStore()
    const [mode, setMode] = useState<"login" | "signup">("login")
    const [email, setEmail] = useState("user@gmail.com")
    const [password, setPassword] = useState("1234")
    const [name, setName] = useState("")
    const [confirmPassword, setConfirmPassword] = useState("")
    const [loading, setLoading] = useState(false)
    const [checking, setChecking] = useState(true)

    useEffect(() => {
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

    function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
        e.preventDefault()
        setLoading(true)
        clearError()
        const ok = login(email, password)
        if (ok) {
            router.replace("/")
        } else {
            setLoading(false)
        }
    }

    if (checking) {
        return (
            <div className="flex h-screen items-center justify-center bg-background">
                <div className="size-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
        )
    }

    const inputCls = "h-11 w-full rounded-xl border border-white/10 bg-white/5 px-4 text-sm text-white placeholder:text-white/40 outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/30"

    return (
        <div className="flex min-h-screen bg-[#0d1117]">

            {/* ── Left hero panel (desktop only) ── */}
            <div className="hidden lg:flex lg:w-[55%] xl:w-[60%] relative flex-col justify-between overflow-hidden">
                {/* Background image overlay */}
                <div className="absolute inset-0 bg-cover bg-center" style={{ backgroundImage: "url('/background.jpg')" }} />
                <div className="absolute inset-0 bg-gradient-to-r from-black/80 via-black/60 to-black/30" />

                <div className="relative z-10 px-10 pt-10">
                    <BrandLogo />
                </div>

                <div className="relative z-10 px-10 pb-16 space-y-6">
                    <div className="space-y-4">
                        <h1 className="text-4xl xl:text-5xl font-bold text-white leading-tight">
                            One platform for worship,<br />community, and<br />stewardship.
                        </h1>
                        <p className="text-sm text-white/70 max-w-md leading-relaxed">
                            This platform empowers African faith communities. Connect with your church, participate in community growth, and manage your contributions with modern precision.
                        </p>
                    </div>
                    <div className="space-y-2">
                        {["Live worship streaming", "Transparent giving", "Governed ministry groups"].map((f) => (
                            <div key={f} className="flex items-center gap-2 text-sm text-white/80">
                                <div className="size-4 rounded-full bg-primary/80 flex items-center justify-center shrink-0">
                                    <svg width="8" height="8" viewBox="0 0 12 10" fill="none"><path d="M1 5l3.5 3.5L11 1" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" /></svg>
                                </div>
                                {f}
                            </div>
                        ))}
                    </div>
                    <div className="flex gap-8 pt-2">
                        <div>
                            <p className="text-2xl font-bold text-white">500+</p>
                            <p className="text-xs text-white/60">Partner Churches</p>
                        </div>
                        <div>
                            <p className="text-2xl font-bold text-white">50k+</p>
                            <p className="text-xs text-white/60">Active Members</p>
                        </div>
                    </div>
                </div>

                <div className="relative z-10 px-10 pb-6">
                    <p className="text-[11px] text-white/40">© 2024 FaithConnect. Ethiopian Protestant Union</p>
                </div>
            </div>

            {/* ── Right form panel ── */}
            <div className="flex flex-1 flex-col items-center justify-center px-6 py-10 lg:bg-[#131920]">

                {/* Mobile brand header */}
                <div className="lg:hidden mb-8 flex flex-col items-center gap-3">
                    <div className="flex size-14 items-center justify-center rounded-2xl bg-primary">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                            <path d="M12 2L2 7l10 5 10-5-10-5z" />
                            <path d="M2 17l10 5 10-5" />
                            <path d="M2 12l10 5 10-5" />
                        </svg>
                    </div>
                    <h1 className="text-2xl font-bold text-white tracking-tight">
                        Faith<span className="text-primary">Connect</span>
                    </h1>
                </div>

                <div className="w-full max-w-[360px] space-y-6">
                    <div>
                        <h2 className="text-xl font-bold text-white">{mode === "login" ? "Welcome Back" : "Create Account"}</h2>
                        <p className="mt-1 text-sm text-white/50">
                            {mode === "login" ? "Sign in to your FaithConnect account" : "Join the FaithConnect community today"}
                        </p>
                    </div>

                    <form onSubmit={handleSubmit} className="space-y-3">
                        {mode === "signup" && (
                            <div className="space-y-1.5">
                                <label className="text-xs font-medium text-white/70">Full Name</label>
                                <div className="relative">
                                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="8" r="4" /><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" /></svg>
                                    </span>
                                    <input type="text" placeholder="John Doe" value={name} onChange={(e) => setName(e.target.value)}
                                        className={`${inputCls} pl-10`} />
                                </div>
                            </div>
                        )}

                        <div className="space-y-1.5">
                            <label className="text-xs font-medium text-white/70">Email Address</label>
                            <div className="relative">
                                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="2" y="4" width="20" height="16" rx="2" /><path d="m2 7 10 7 10-7" /></svg>
                                </span>
                                <input id="email" type="email" autoComplete="email" placeholder="name@church.org"
                                    value={email} onChange={(e) => setEmail(e.target.value)}
                                    className={`${inputCls} pl-10`} />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <div className="flex items-center justify-between">
                                <label className="text-xs font-medium text-white/70">Password</label>
                                {mode === "login" && (
                                    <button type="button" className="text-[11px] text-primary hover:underline">Forgot password?</button>
                                )}
                            </div>
                            <div className="relative">
                                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="11" width="18" height="11" rx="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>
                                </span>
                                <input id="password" type="password" autoComplete={mode === "login" ? "current-password" : "new-password"} placeholder="••••••••"
                                    value={password} onChange={(e) => setPassword(e.target.value)}
                                    className={`${inputCls} pl-10`} />
                            </div>
                        </div>

                        {mode === "signup" && (
                            <div className="space-y-1.5">
                                <label className="text-xs font-medium text-white/70">Confirm Password</label>
                                <div className="relative">
                                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-white/30">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="11" width="18" height="11" rx="2" /><path d="M7 11V7a5 5 0 0 1 10 0v4" /></svg>
                                    </span>
                                    <input type="password" autoComplete="new-password" placeholder="••••••••"
                                        value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)}
                                        className={`${inputCls} pl-10`} />
                                </div>
                            </div>
                        )}

                        {mode === "login" && (
                            <label className="flex items-center gap-2 text-xs text-white/60 cursor-pointer">
                                <input type="checkbox" className="size-3.5 rounded accent-primary" />
                                Keep me logged in
                            </label>
                        )}

                        {loginError && (
                            <p className="text-xs text-red-400 text-center">{loginError}</p>
                        )}

                        <Button type="submit" disabled={loading}
                            className="h-11 w-full rounded-xl text-sm font-semibold gap-2 mt-1">
                            {loading ? "Please wait..." : mode === "login" ? "Sign In →" : "Create Account →"}
                        </Button>

                        {mode === "login" && (
                            <p className="text-center text-[11px] text-white/40">
                                Demo: <span className="font-mono">user@gmail.com</span> / <span className="font-mono">user2</span> &nbsp;(password: <span className="font-mono">1234</span>)
                            </p>
                        )}
                    </form>

                    <div className="relative flex items-center gap-3">
                        <div className="flex-1 h-px bg-white/10" />
                        <span className="text-[11px] text-white/40">OR SIGN IN WITH</span>
                        <div className="flex-1 h-px bg-white/10" />
                    </div>

                    <button type="button"
                        className="flex h-11 w-full items-center justify-center gap-2.5 rounded-xl border border-white/10 bg-white/5 text-sm text-white/80 hover:bg-white/10 transition-colors">
                        <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" /><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" /><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" /><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" /></svg>
                        Google Account
                    </button>

                    <p className="text-center text-xs text-white/50">
                        {mode === "login" ? (
                            <>Don&apos;t have an account?{" "}
                                <button type="button" onClick={() => setMode("signup")} className="text-primary hover:underline font-medium">Request Access</button>
                            </>
                        ) : (
                            <>Already have an account?{" "}
                                <button type="button" onClick={() => setMode("login")} className="text-primary hover:underline font-medium">Sign In</button>
                            </>
                        )}
                    </p>

                    <div className="flex justify-center gap-4 text-[10px] text-white/30">
                        <button className="hover:text-white/60">Privacy</button>
                        <button className="hover:text-white/60">Terms</button>
                        <button className="hover:text-white/60">Contact Support</button>
                    </div>
                </div>
            </div>
        </div>
    )
}

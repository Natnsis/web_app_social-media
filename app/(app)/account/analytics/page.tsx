"use client"

import { useState } from "react"
import Link from "next/link"
import { ArrowLeft, BarChart3, TrendingUp, Users, DollarSign } from "lucide-react"
import { Heart, Eye } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { cn } from "@/lib/utils"
import { useChurchAnalytics } from "@/hooks/use-analytics"

type Range = "week" | "month" | "year"

type MetricCardProps = {
    label: string
    value: string
    change: string
    positive: boolean
    Icon: React.ElementType
}

type ActivityItem = {
    id: string
    type: "donation" | "follower" | "engagement"
    title: string
    subtitle: string
    time: string
}

type TopContent = {
    id: string
    title: string
    views: string
    engagement: string
}

const dateRanges: { key: Range; label: string }[] = [
    { key: "week", label: "This Week" },
    { key: "month", label: "This Month" },
    { key: "year", label: "This Year" },
]

const icnMap: Record<string, React.ElementType> = {
    Eye,
    Heart,
    Users,
    DollarSign,
}

function SkeletonMetricCards() {
    return (
        <>
            {[1, 2, 3, 4].map((i) => (
                <div key={i} className="animate-pulse rounded-2xl border border-border bg-card p-4">
                    <div className="mb-3 size-10 rounded-xl bg-muted" />
                    <div className="space-y-2">
                        <div className="h-3 w-20 rounded bg-muted" />
                        <div className="h-7 w-28 rounded bg-muted" />
                        <div className="h-3 w-16 rounded bg-muted" />
                    </div>
                </div>
            ))}
        </>
    )
}

function MetricCard({ label, value, change, positive, Icon }: MetricCardProps) {
    return (
        <div className="rounded-2xl border border-border bg-card p-4 transition-colors hover:border-primary/20">
            <div className="mb-3 flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <Icon size={18} />
            </div>
            <p className="text-xs font-medium text-muted-foreground">{label}</p>
            <p className="mt-0.5 text-2xl font-black tracking-tight">{value}</p>
            <p className={cn("mt-1 text-xs font-semibold", positive ? "text-green-500" : "text-red-500")}>
                {change} <span className="font-normal text-muted-foreground">vs last period</span>
            </p>
        </div>
    )
}

function ChartSection({ data }: { data: number[] }) {
    const maxVal = Math.max(...data, 1)
    return (
        <div className="rounded-2xl border border-border bg-card p-4 lg:p-6">
            <div className="flex items-center justify-between">
                <div>
                    <h3 className="flex items-center gap-1.5 text-sm font-bold">
                        <BarChart3 size={15} className="text-primary" /> Reach Overview
                    </h3>
                    <p className="text-xs text-muted-foreground">Daily unique reach for selected period</p>
                </div>
                <select className="rounded-xl border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground outline-none">
                    <option>Posts</option>
                    <option>Shorts</option>
                    <option>All</option>
                </select>
            </div>
            <div className="mt-6 flex h-48 items-end gap-1.5 lg:h-56">
                {data.map((h, i) => (
                    <div key={i} className="group relative flex flex-1 flex-col items-center justify-end">
                        <div
                            className="w-full rounded-t-lg bg-primary transition-all hover:bg-primary/80"
                            style={{ height: `${(h / maxVal) * 100}%` }}
                        >
                            <div className="absolute -top-8 left-1/2 hidden -translate-x-1/2 rounded-lg bg-foreground px-2 py-1 text-xs font-medium text-background group-hover:block">
                                {h}
                            </div>
                        </div>
                    </div>
                ))}
            </div>
            <div className="mt-2 flex justify-between px-0.5">
                {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"].map((d, i) => (
                    <span key={i} className="text-[10px] font-medium text-muted-foreground">{d}</span>
                ))}
            </div>
        </div>
    )
}

function ActivityFeed({ items }: { items: ActivityItem[] }) {
    return (
        <div className="rounded-2xl border border-border bg-card p-4 lg:p-6">
            <h3 className="mb-4 text-sm font-bold">Recent Activity</h3>
            <div className="space-y-1">
                {items.map((item) => (
                    <div key={item.id} className="flex items-start gap-3 rounded-xl p-2.5 transition-colors hover:bg-muted/50">
                        <div className={cn(
                            "mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-lg",
                            item.type === "donation" ? "bg-green-500/10 text-green-500" :
                            item.type === "follower" ? "bg-blue-500/10 text-blue-500" :
                            "bg-amber-500/10 text-amber-500"
                        )}>
                            {item.type === "donation" ? <DollarSign size={14} /> :
                             item.type === "follower" ? <Users size={14} /> :
                             <TrendingUp size={14} />}
                        </div>
                        <div className="min-w-0 flex-1">
                            <p className="text-sm font-semibold leading-tight">{item.title}</p>
                            <p className="truncate text-xs text-muted-foreground">{item.subtitle}</p>
                        </div>
                        <span className="shrink-0 text-[10px] font-medium text-muted-foreground">{item.time}</span>
                    </div>
                ))}
            </div>
        </div>
    )
}

function TopContentSection({ items }: { items: TopContent[] }) {
    return (
        <div className="rounded-2xl border border-border bg-card p-4 lg:p-6">
            <div className="mb-4 flex items-center justify-between">
                <h3 className="text-sm font-bold">Top Content</h3>
                <Button variant="ghost" size="xs" className="rounded-full text-primary text-[10px]">View all</Button>
            </div>
            <div className="space-y-2">
                {items.map((item) => (
                    <div key={item.id} className="flex items-center justify-between rounded-xl bg-muted/40 px-3 py-2.5">
                        <div className="min-w-0 flex-1">
                            <p className="truncate text-xs font-semibold">{item.title}</p>
                            <p className="text-[10px] text-muted-foreground">{item.views} views</p>
                        </div>
                        <div className="ml-3 shrink-0 text-right">
                            <p className="text-xs font-bold text-green-500">{item.engagement}</p>
                            <p className="text-[10px] text-muted-foreground">engagement</p>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    )
}

function SummaryPanel({ totalReach, engagementGrowth, totalDonations }: { totalReach: string; engagementGrowth: string; totalDonations: string }) {
    return (
        <aside className="hidden shrink-0 flex-col gap-4 xl:flex xl:w-72">
            <div className="rounded-2xl border border-border bg-card p-4">
                <div className="rounded-xl bg-primary p-4 text-primary-foreground">
                    <p className="text-xs font-bold uppercase tracking-wider text-primary-foreground/70">Period Summary</p>
                    <div className="mt-4 space-y-3">
                        <div>
                            <p className="text-2xl font-black">{totalReach}</p>
                            <p className="text-[11px] text-primary-foreground/70">total reach</p>
                        </div>
                        <Separator className="bg-primary-foreground/20" />
                        <div>
                            <p className="text-2xl font-black">{engagementGrowth}</p>
                            <p className="text-[11px] text-primary-foreground/70">engagement growth</p>
                        </div>
                        <Separator className="bg-primary-foreground/20" />
                        <div>
                            <p className="text-2xl font-black">{totalDonations}</p>
                            <p className="text-[11px] text-primary-foreground/70">total donations</p>
                        </div>
                    </div>
                </div>
            </div>

            <div className="rounded-2xl border border-border bg-card p-4">
                <p className="mb-3 flex items-center gap-1.5 text-xs font-bold"><TrendingUp size={13} className="text-primary" /> Quick Insights</p>
                <div className="space-y-2.5">
                    <div className="rounded-xl border border-border bg-background p-3">
                        <p className="text-xs font-semibold">Best posting time</p>
                        <p className="text-[10px] text-muted-foreground">Sundays at 9:00 AM</p>
                    </div>
                    <div className="rounded-xl border border-border bg-background p-3">
                        <p className="text-xs font-semibold">Top content type</p>
                        <p className="text-[10px] text-muted-foreground">Live streams (+45% reach)</p>
                    </div>
                    <div className="rounded-xl border border-border bg-background p-3">
                        <p className="text-xs font-semibold">Audience growth</p>
                        <p className="text-[10px] text-muted-foreground">+482 followers this month</p>
                    </div>
                </div>
            </div>
        </aside>
    )
}

export default function AnalyticsPage() {
    const [range, setRange] = useState<Range>("month")
    const { data: analyticsData, isLoading, isError, error, refetch } = useChurchAnalytics(range)

    const metrics = analyticsData?.data?.metrics ?? []
    const chartData = analyticsData?.data?.chartData ?? []
    const activityItems = analyticsData?.data?.recentActivity ?? []
    const topContentItems = analyticsData?.data?.topContent ?? []
    const summary = analyticsData?.data?.periodSummary ?? { totalReach: "0", engagementGrowth: "0", totalDonations: "$0" }

    if (isError) {
        return (
            <div className="flex h-full flex-col items-center justify-center gap-4 p-8">
                <p className="text-sm text-muted-foreground">{(error as Error)?.message ?? "Failed to load analytics"}</p>
                <Button variant="outline" size="sm" onClick={() => refetch()}>Try again</Button>
            </div>
        )
    }

    return (
        <>
            {/* ── Mobile layout ── */}
            <div className="relative flex h-full flex-col overflow-hidden lg:hidden">
                <header className="flex shrink-0 items-center gap-3 border-b border-border px-4 py-3">
                    <Link href="/account">
                        <Button variant="ghost" size="icon-sm" aria-label="Back">
                            <ArrowLeft size={20} />
                        </Button>
                    </Link>
                    <h1 className="text-lg font-bold">Analytics</h1>
                </header>

                <div className="flex-1 overflow-y-auto pb-24">
                    <div className="space-y-4 p-4">
                        {/* Date range selector */}
                        <div className="flex gap-2 rounded-2xl border border-border bg-card p-1">
                            {dateRanges.map(({ key, label }) => (
                                <button key={key} onClick={() => setRange(key)}
                                    className={cn(
                                        "flex-1 rounded-xl px-3 py-2 text-xs font-semibold transition-colors",
                                        range === key ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
                                    )}>
                                    {label}
                                </button>
                            ))}
                        </div>

                        {/* Metric cards */}
                        <div className="grid grid-cols-2 gap-3">
                            {isLoading ? <SkeletonMetricCards /> : metrics.map((card) => {
                                const Icon = icnMap[card.label === "Total Reach" ? "Eye" : card.label === "Engagement Rate" ? "Heart" : card.label === "New Followers" ? "Users" : "DollarSign"] ?? Eye
                                return <MetricCard key={card.label} {...card} Icon={Icon} />
                            })}
                        </div>

                        {/* Chart */}
                        <ChartSection data={chartData} />

                        {/* Activity feed */}
                        <ActivityFeed items={activityItems} />

                        {/* Top content */}
                        <TopContentSection items={topContentItems} />
                    </div>
                </div>
            </div>

            {/* ── Desktop layout ── */}
            <div className="hidden h-full overflow-y-auto bg-background lg:block">
                <div className="mx-auto w-full max-w-5xl px-8 py-8">
                    <div className="mb-6 flex items-center justify-between">
                        <div>
                            <h1 className="text-2xl font-black tracking-tight">Analytics</h1>
                            <p className="text-sm text-muted-foreground">Track your church&apos;s growth and engagement</p>
                        </div>
                        {/* Date range */}
                        <div className="flex gap-1.5 rounded-2xl border border-border bg-card p-1">
                            {dateRanges.map(({ key, label }) => (
                                <button key={key} onClick={() => setRange(key)}
                                    className={cn(
                                        "rounded-xl px-4 py-2 text-xs font-semibold transition-colors",
                                        range === key ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
                                    )}>
                                    {label}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="flex gap-8">
                        <div className="min-w-0 flex-1 space-y-5">
                            {/* Metric cards */}
                            <div className="grid grid-cols-4 gap-4">
                                {isLoading ? <SkeletonMetricCards /> : metrics.map((card) => {
                                    const Icon = icnMap[card.label === "Total Reach" ? "Eye" : card.label === "Engagement Rate" ? "Heart" : card.label === "New Followers" ? "Users" : "DollarSign"] ?? Eye
                                    return <MetricCard key={card.label} {...card} Icon={Icon} />
                                })}
                            </div>

                            {/* Chart */}
                            <ChartSection data={chartData} />

                            <div className="grid grid-cols-2 gap-5">
                                <ActivityFeed items={activityItems} />
                                <TopContentSection items={topContentItems} />
                            </div>
                        </div>

                        {/* Summary panel */}
                        <SummaryPanel
                            totalReach={summary.totalReach}
                            engagementGrowth={summary.engagementGrowth}
                            totalDonations={summary.totalDonations}
                        />
                    </div>
                </div>
            </div>
        </>
    )
}

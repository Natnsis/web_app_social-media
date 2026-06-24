"use client"

import Link from "next/link"
import { ChevronLeft, Wallet, CreditCard } from "lucide-react"
import { Bank, Gift, Heart, ArrowRightFromBracket } from "nasicon-react/outline"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { useQuery } from "@tanstack/react-query"
import { apiGetWallet } from "@/lib/api/wallet"
import type { WalletTransaction, ChurchWallet } from "@/lib/api/wallet"
import type { ChurchPaymentAccount } from "@/types"

const quickActions = [
  { label: "Add Funds", icon: Wallet, color: "bg-blue-50 dark:bg-blue-950", iconColor: "text-blue-500" },
  { label: "Withdraw", icon: ArrowRightFromBracket, color: "bg-green-50 dark:bg-green-950", iconColor: "text-green-500" },
  { label: "Send Gift", icon: Gift, color: "bg-pink-50 dark:bg-pink-950", iconColor: "text-pink-500" },
]

function formatAmount(amount: number, currency: string) {
  return `${currency} ${amount.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
}

function formatDate(dateString: string) {
  const d = new Date(dateString)
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) + " • " + d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" })
}

function statusColor(status: string) {
  switch (status) {
    case "success": return "text-green-600 bg-green-50 dark:bg-green-950 dark:text-green-400"
    case "pending": return "text-amber-600 bg-amber-50 dark:bg-amber-950 dark:text-amber-400"
    case "failed": return "text-red-600 bg-red-50 dark:bg-red-950 dark:text-red-400"
    default: return "text-muted-foreground bg-muted"
  }
}

function TransactionIcon({ type }: { type: string }) {
  const isDonation = type === "donation"
  const bg = isDonation ? "bg-blue-50 dark:bg-blue-950" : "bg-pink-50 dark:bg-pink-950"
  const color = isDonation ? "text-blue-500" : "text-pink-500"
  const iconSize = 18
  const icon = (() => {
    switch (type) {
      case "donation": return <Heart size={iconSize} className={color} />
      case "withdrawal": return <ArrowRightFromBracket size={iconSize} className={color} />
      case "deposit": return <Wallet size={iconSize} className={color} />
      case "gift": return <Gift size={iconSize} className={color} />
      default: return <CreditCard size={iconSize} className={color} />
    }
  })()
  return (
    <div className={`flex size-10 shrink-0 items-center justify-center rounded-full ${bg}`}>
      {icon}
    </div>
  )
}

function BalanceCard({ wallet, loading }: { wallet?: ChurchWallet | null; loading: boolean }) {
  return (
    <div className="rounded-2xl bg-gradient-to-br from-blue-500 to-blue-600 p-6 text-white shadow-lg shadow-blue-500/25">
      <div className="flex items-center gap-3">
        <div className="flex size-10 items-center justify-center rounded-xl bg-white/20">
          <Wallet size={20} />
        </div>
        <p className="text-sm font-medium text-white/80">Wallet Balance</p>
      </div>
      <div className="mt-4">
        {loading && !wallet ? (
          <div className="h-9 w-48 animate-pulse rounded-lg bg-white/20" />
        ) : (
          <p className="text-3xl font-black tracking-tight">
            {wallet ? formatAmount(wallet.balanceEtb, wallet.currency) : "ETB 0.00"}
          </p>
        )}
      </div>
      <div className="mt-5 flex gap-2">
        <Button size="sm" variant="secondary" className="rounded-xl bg-white/20 text-white hover:bg-white/30">
          <ArrowRightFromBracket size={14} className="mr-1.5" />
          Withdraw
        </Button>
        <Button size="sm" variant="secondary" className="rounded-xl bg-white/20 text-white hover:bg-white/30">
          <Wallet size={14} className="mr-1.5" />
          Add Funds
        </Button>
      </div>
    </div>
  )
}

function QuickActions() {
  return (
    <div className="grid grid-cols-3 gap-3">
      {quickActions.map((action) => (
        <button
          key={action.label}
          className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-4 transition-colors hover:bg-muted/50"
        >
          <div className={`flex size-11 items-center justify-center rounded-full ${action.color}`}>
            <action.icon size={20} className={action.iconColor} />
          </div>
          <span className="text-xs font-semibold text-foreground">{action.label}</span>
        </button>
      ))}
    </div>
  )
}

function TransactionCard({ tx }: { tx: WalletTransaction }) {
  return (
    <div className="flex items-start gap-3 rounded-xl border border-border bg-card p-4">
      <TransactionIcon type={tx.type} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold text-foreground">{tx.title}</p>
        {tx.subtitle && <p className="mt-0.5 truncate text-xs text-muted-foreground">{tx.subtitle}</p>}
        <div className="mt-1.5 flex items-center gap-1.5">
          <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-medium ${statusColor(tx.status)}`}>
            {tx.status.charAt(0).toUpperCase() + tx.status.slice(1)}
          </span>
        </div>
      </div>
      <div className="shrink-0 text-right">
        <p className="text-sm font-bold text-foreground">
          {tx.type === "withdrawal" ? "-" : "+"}{formatAmount(tx.amount, tx.currency)}
        </p>
        <p className="mt-0.5 text-[10px] text-muted-foreground">{formatDate(tx.createdAt)}</p>
      </div>
    </div>
  )
}

function TransactionSkeleton() {
  return (
    <div className="space-y-3">
      {[1, 2, 3, 4, 5].map((i) => (
        <div key={i} className="flex animate-pulse items-start gap-3 rounded-xl border border-border bg-card p-4">
          <div className="size-10 rounded-full bg-muted" />
          <div className="min-w-0 flex-1 space-y-2">
            <div className="h-4 w-36 rounded bg-muted" />
            <div className="h-3 w-24 rounded bg-muted" />
            <div className="h-5 w-16 rounded-full bg-muted" />
          </div>
          <div className="space-y-2 text-right">
            <div className="h-4 w-20 rounded bg-muted" />
            <div className="h-3 w-16 rounded bg-muted" />
          </div>
        </div>
      ))}
    </div>
  )
}

function PaymentAccountCard({ account }: { account: ChurchPaymentAccount }) {
  return (
    <div className="flex items-center gap-3 rounded-xl border border-border bg-card p-4">
      <div className="flex size-10 shrink-0 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
        <Bank size={18} className="text-blue-500" />
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-sm font-semibold text-foreground">{account.accountName}</p>
        <p className="text-xs text-muted-foreground">{account.provider} • {account.accountNumber}</p>
      </div>
      {account.isVerified ? (
        <span className="text-xs font-medium text-green-600">Verified</span>
      ) : (
        <span className="text-xs font-medium text-amber-600">Pending</span>
      )}
    </div>
  )
}

function PaymentAccountSkeleton() {
  return (
    <div className="space-y-3">
      {[1, 2].map((i) => (
        <div key={i} className="flex animate-pulse items-center gap-3 rounded-xl border border-border bg-card p-4">
          <div className="size-10 rounded-full bg-muted" />
          <div className="flex-1 space-y-2">
            <div className="h-4 w-36 rounded bg-muted" />
            <div className="h-3 w-24 rounded bg-muted" />
          </div>
          <div className="h-4 w-14 rounded bg-muted" />
        </div>
      ))}
    </div>
  )
}

function MobileWallet() {
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ["wallet"],
    queryFn: apiGetWallet,
  })

  const wallet = data?.data?.wallet ?? null
  const transactions = data?.data?.transactions ?? []
  const paymentAccounts = data?.data?.paymentAccounts ?? []

  return (
    <div className="flex h-full w-full flex-col overflow-hidden bg-background">
      <header className="flex shrink-0 items-center gap-2 px-4 py-3">
        <Link href="/account" className="text-primary">
          <ChevronLeft size={22} />
        </Link>
        <h1 className="text-lg font-bold text-primary">Wallet</h1>
      </header>

      <div className="flex-1 overflow-y-auto px-4 pb-8">
        <div className="space-y-6">
          <BalanceCard wallet={wallet} loading={isLoading} />

          <QuickActions />

          <Separator />

          {/* Payment Accounts */}
          <div>
            <div className="mb-3 flex items-center justify-between">
              <h2 className="text-base font-bold text-foreground">Payment Accounts</h2>
              <Button variant="ghost" size="xs" className="rounded-full text-xs text-primary">Add</Button>
            </div>
            {isLoading ? (
              <PaymentAccountSkeleton />
            ) : paymentAccounts.length === 0 ? (
              <div className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-6 text-center">
                <Bank size={28} className="text-muted-foreground" />
                <p className="text-sm font-semibold text-foreground">No Payment Accounts</p>
                <p className="text-xs text-muted-foreground">Add a payment account to receive payouts.</p>
                <Button variant="outline" size="sm" className="mt-2 rounded-xl">Add Payment Account</Button>
              </div>
            ) : (
              <div className="space-y-3">
                {paymentAccounts.map((account) => (
                  <PaymentAccountCard key={account.id} account={account} />
                ))}
              </div>
            )}
          </div>

          <Separator />

          {/* Transaction History */}
          <div>
            <h2 className="mb-3 text-base font-bold text-foreground">Transactions</h2>
            {isLoading ? (
              <TransactionSkeleton />
            ) : isError ? (
              <div className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-card p-8 text-center">
                <p className="text-sm text-muted-foreground">Failed to load transactions</p>
                <Button variant="outline" size="sm" className="rounded-xl" onClick={() => refetch()}>Try again</Button>
              </div>
            ) : transactions.length === 0 ? (
              <div className="flex flex-col items-center gap-2 rounded-2xl border border-border bg-card p-6 text-center">
                <CreditCard size={28} className="text-muted-foreground" />
                <p className="text-sm font-semibold text-foreground">No transactions yet</p>
                <p className="text-xs text-muted-foreground">Your transaction history will appear here.</p>
              </div>
            ) : (
              <div className="space-y-3">
                {transactions.map((tx) => (
                  <TransactionCard key={tx.id} tx={tx} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function DesktopWallet() {
  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ["wallet"],
    queryFn: apiGetWallet,
  })

  const wallet = data?.data?.wallet ?? null
  const transactions = data?.data?.transactions ?? []
  const paymentAccounts = data?.data?.paymentAccounts ?? []

  return (
    <div className="mx-auto h-full max-w-4xl overflow-y-auto px-8 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-black tracking-tight text-foreground">Wallet</h1>
        <p className="mt-1 text-sm text-muted-foreground">Manage your church wallet, transactions, and payment accounts</p>
      </div>
      <div className="grid grid-cols-[1fr_360px] gap-8">
        {/* Left Column */}
        <div className="space-y-6">
          <BalanceCard wallet={wallet} loading={isLoading} />

          {/* Transaction History */}
          <section className="rounded-2xl border border-border bg-card p-6">
            <h2 className="text-lg font-black text-foreground">Transaction History</h2>
            <p className="mt-1 text-sm text-muted-foreground">Recent wallet activity.</p>
            <div className="mt-6">
              {isLoading ? (
                <TransactionSkeleton />
              ) : isError ? (
                <div className="flex flex-col items-center gap-3 rounded-xl bg-muted/50 p-8 text-center">
                  <p className="text-sm text-muted-foreground">Failed to load transactions</p>
                  <Button variant="outline" size="sm" className="rounded-xl" onClick={() => refetch()}>Try again</Button>
                </div>
              ) : transactions.length === 0 ? (
                <div className="flex flex-col items-center gap-2 rounded-xl bg-muted/50 p-8 text-center">
                  <CreditCard size={28} className="text-muted-foreground" />
                  <p className="text-sm font-semibold text-foreground">No transactions yet</p>
                  <p className="text-xs text-muted-foreground">Your transaction history will appear here.</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {transactions.map((tx) => (
                    <TransactionCard key={tx.id} tx={tx} />
                  ))}
                </div>
              )}
            </div>
          </section>
        </div>

        {/* Right Column */}
        <aside className="space-y-6">
          {/* Quick Actions */}
          <section className="rounded-2xl border border-border bg-card p-5">
            <h2 className="text-sm font-black text-foreground">Quick Actions</h2>
            <div className="mt-4 space-y-2">
              {quickActions.map((action) => (
                <button
                  key={action.label}
                  className="flex w-full items-center gap-3 rounded-xl border border-border bg-background p-3 text-left transition-colors hover:bg-muted/50"
                >
                  <div className={`flex size-10 items-center justify-center rounded-full ${action.color}`}>
                    <action.icon size={18} className={action.iconColor} />
                  </div>
                  <span className="text-sm font-semibold text-foreground">{action.label}</span>
                </button>
              ))}
            </div>
          </section>

          {/* Payment Accounts */}
          <section className="rounded-2xl border border-border bg-card p-5">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-black text-foreground">Payment Accounts</h2>
              <Button variant="ghost" size="xs" className="rounded-full text-xs text-primary">Add</Button>
            </div>
            <div className="mt-4">
              {isLoading ? (
                <PaymentAccountSkeleton />
              ) : paymentAccounts.length === 0 ? (
                <div className="flex flex-col items-center gap-2 rounded-xl bg-muted/50 p-6 text-center">
                  <Bank size={24} className="text-muted-foreground" />
                  <p className="text-sm font-semibold text-foreground">No accounts</p>
                  <p className="text-xs text-muted-foreground">Add a payment account to receive payouts.</p>
                  <Button variant="outline" size="sm" className="mt-1 rounded-xl">Add Account</Button>
                </div>
              ) : (
                <div className="space-y-3">
                  {paymentAccounts.map((account) => (
                    <PaymentAccountCard key={account.id} account={account} />
                  ))}
                </div>
              )}
            </div>
          </section>
        </aside>
      </div>
    </div>
  )
}

export default function WalletPage() {
  return (
    <>
      <div className="hidden h-full overflow-hidden lg:block">
        <DesktopWallet />
      </div>
      <div className="lg:hidden h-full overflow-hidden">
        <MobileWallet />
      </div>
    </>
  )
}

import { get, post } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { ApiResponse, ChurchPaymentAccount } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface WalletTransaction {
  id: string
  type: "donation" | "withdrawal" | "deposit" | "gift" | "refund"
  title: string
  subtitle: string | null
  amount: number
  currency: string
  status: "success" | "pending" | "failed"
  createdAt: string
  iconUrl: string | null
}

export interface ChurchWallet {
  id: string
  churchId: string
  balanceEtb: number
  currency: string
  updatedAt: string
}

export interface WalletResponse {
  success: boolean
  data: {
    wallet: ChurchWallet
    transactions: WalletTransaction[]
    paymentAccounts: ChurchPaymentAccount[]
  }
}

const mockWallet: ChurchWallet = {
  id: "wallet-1",
  churchId: "church-1",
  balanceEtb: 0,
  currency: "ETB",
  updatedAt: new Date().toISOString(),
}

const mockTransactions: WalletTransaction[] = []

const mockPaymentAccounts: ChurchPaymentAccount[] = []

export function apiGetWallet() {
  return get<WalletResponse>("/v1/wallet", token()).catch(() => ({
    success: true,
    data: {
      wallet: mockWallet,
      transactions: mockTransactions,
      paymentAccounts: mockPaymentAccounts,
    },
  }))
}

export function apiAddPaymentAccount(data: {
  provider: string
  accountName: string
  accountNumber: string
  providerAccountId?: string
}) {
  return post<ApiResponse>("/v1/wallet/payment-accounts", data, token())
}

export function apiRequestWithdrawal(paymentAccountId: string, amountEtb: number) {
  return post<ApiResponse>("/v1/wallet/withdraw", { paymentAccountId, amountEtb }, token())
}

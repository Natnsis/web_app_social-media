import { get, post } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { ApiResponse } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface GiftItem {
  id: string
  name: string
  description: string | null
  priceAmount: number
  priceCurrency: string
  imageUrl: string | null
  createdAt: string
}

export interface SendGiftPayload {
  giftId: string
  recipientUserId: string
  message?: string
}

export interface GiftFeedItem {
  id: string
  giftItem: GiftItem
  senderUser: {
    id: string
    fullName: string
    avatarUrl: string | null
  }
  recipientUserId: string
  message: string | null
  createdAt: string
}

export interface GiftsResponse {
  success: boolean
  data: GiftItem[]
  meta: { total: number }
}

export interface GiftFeedResponse {
  success: boolean
  data: GiftFeedItem[]
  meta: { total: number; skip: number; take: number }
}

export function apiGetGifts() {
  return get<GiftsResponse>("/v1/gifting/catalog", token())
}

export function apiGetGiftFeed(skip = 0, take = 20) {
  return get<GiftFeedResponse>(`/v1/gifting/feed?skip=${skip}&take=${take}`, token())
}

export function apiSendGift(payload: SendGiftPayload) {
  return post<ApiResponse>("/v1/gifting/send", payload, token())
}

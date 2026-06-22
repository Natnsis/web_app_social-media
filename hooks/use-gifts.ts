"use client"

import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"
import { apiGetGifts, apiGetGiftFeed, apiSendGift } from "@/lib/api/gifts"
import type { SendGiftPayload } from "@/lib/api/gifts"

export function useGifts(enabled = true) {
  return useQuery({
    queryKey: ["gifts-catalog"],
    queryFn: apiGetGifts,
    enabled,
  })
}

export function useGiftFeed(skip = 0, take = 20, enabled = true) {
  return useQuery({
    queryKey: ["gift-feed", skip, take],
    queryFn: () => apiGetGiftFeed(skip, take),
    enabled,
  })
}

export function useSendGift() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (payload: SendGiftPayload) => apiSendGift(payload),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["gift-feed"] })
    },
  })
}

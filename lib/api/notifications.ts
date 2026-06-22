import { get, post, del } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { NotificationsResponse, MarkReadPayload, ApiResponse } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface NotificationPreferences {
  enablePush: boolean
  enableEmail: boolean
  enableInApp: boolean
}

export interface UpdateNotificationPreferencesPayload {
  enablePush?: boolean
  enableEmail?: boolean
  enableInApp?: boolean
}

export interface RegisterPushDevicePayload {
  deviceToken: string
  platform: "ios" | "android" | "web"
  deviceName?: string
}

export function apiGetNotifications(skip = 0, take = 20) {
  return get<NotificationsResponse>(`/v1/notifications?skip=${skip}&take=${take}`, token())
}

export function apiMarkNotificationRead(notificationId: string) {
  return post<ApiResponse>(`/v1/notifications/${notificationId}/read`, {}, token())
}

export function apiMarkAllRead() {
  return post<ApiResponse>("/v1/notifications/read-all", {}, token())
}

export function apiGetNotificationPreferences() {
  return get<{ success: boolean; data: NotificationPreferences }>("/v1/notifications/preferences", token())
}

export function apiUpdateNotificationPreferences(payload: UpdateNotificationPreferencesPayload) {
  return post<ApiResponse>("/v1/notifications/preferences", payload, token())
}

export function apiRegisterPushDevice(payload: RegisterPushDevicePayload) {
  return post<ApiResponse>("/v1/notifications/devices", payload, token())
}

export function apiUnregisterPushDevice(deviceToken: string) {
  return del<ApiResponse>(`/v1/notifications/devices/${deviceToken}`, token())
}

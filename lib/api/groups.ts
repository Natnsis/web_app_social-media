import { get, post } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  GroupCommentsResponse,
  CreateGroupPayload,
  CreateGroupResponse,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetGroupComments(groupId: string, skip = 0, take = 30) {
  return get<GroupCommentsResponse>(`/v1/groups/${groupId}/comments?skip=${skip}&take=${take}`, token())
}

export function apiCreateGroup(payload: CreateGroupPayload) {
  return post<CreateGroupResponse>("/v1/groups", payload, token())
}

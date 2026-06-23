import { get, post, del, postFormData, patchFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  GroupCommentsResponse,
  CreateGroupPayload,
  CreateGroupResponse,
  GroupsResponse,
  GroupMembersResponse,
  ApiResponse,
  MinimalGroup,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetGroups() {
  return get<GroupsResponse>("/v1/groups", token())
}

export function apiGetGroupComments(groupId: string, skip = 0, take = 30) {
  return get<GroupCommentsResponse>(`/v1/groups/${groupId}/comments?skip=${skip}&take=${take}`, token())
}

export function apiCreateGroup(payload: CreateGroupPayload) {
  return post<CreateGroupResponse>("/v1/groups", payload, token())
}

export function apiCreateGroupFormData(formData: FormData) {
  return postFormData<CreateGroupResponse>("/v1/groups", formData, token())
}

export function apiUpdateGroup(id: string, formData: FormData) {
  return patchFormData<ApiResponse<MinimalGroup>>(`/v1/groups/${id}`, formData, token())
}

export function apiDeleteGroup(id: string) {
  return del<ApiResponse<{ id: string }>>(`/v1/groups/${id}`, token())
}

export function apiGetGroupMembers(id: string) {
  return get<GroupMembersResponse>(`/v1/groups/${id}/members`, token())
}

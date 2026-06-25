/** Mirrors lib/lib/core/models/app_user_role.dart */

export const AppUserRole = {
  user: "USER",
  churchAdmin: "CHURCH_ADMIN",
  churchOwner: "CHURCH_OWNER",
  admin: "ADMIN",
  superAdmin: "SUPER_ADMIN",
} as const

export type AppUserRoleValue = (typeof AppUserRole)[keyof typeof AppUserRole]

const ELEVATED_ROLES = new Set<string>([
  AppUserRole.churchAdmin,
  AppUserRole.churchOwner,
  AppUserRole.admin,
  AppUserRole.superAdmin,
])

export function normalizeRoles(raw: unknown): string[] {
  if (!Array.isArray(raw)) return []
  const normalized = new Set<string>()
  for (const entry of raw) {
    if (typeof entry === "string" && entry.trim()) {
      normalized.add(entry.trim().replace(/[\s-]+/g, "_").toUpperCase())
    }
  }
  return [...normalized]
}

export function canManageChurchContent(roles: string[]): boolean {
  if (roles.length === 0) return false
  return roles.some((role) => ELEVATED_ROLES.has(role.toUpperCase()))
}

export function isCommunityMemberOnly(roles: string[]): boolean {
  if (roles.length === 0) return true
  return !canManageChurchContent(roles) && roles.map((r) => r.toUpperCase()).includes(AppUserRole.user)
}

export function primaryRoleLabel(roles: string[]): string {
  return canManageChurchContent(roles) ? "Church Administrator" : "Community Member"
}

export function organizationBadgeLabel(roles: string[]): string {
  const normalized = new Set(roles.map((r) => r.toUpperCase()))
  if (normalized.has(AppUserRole.superAdmin)) return "SUPER"
  if (normalized.has(AppUserRole.admin)) return "ADMIN"
  if (normalized.has(AppUserRole.churchOwner)) return "OWNER"
  if (normalized.has(AppUserRole.churchAdmin)) return "ADMIN"
  return "MEMBER"
}

export function isChurchOwner(roles: string[]): boolean {
  return roles.map((r) => r.toUpperCase()).includes(AppUserRole.churchOwner)
}

import { z } from "zod"

export const updateProfileSchema = z.object({
  fullName: z.string().min(2, "Full name must be at least 2 characters"),
  bio: z.string().max(500, "Bio must be under 500 characters").optional(),
  email: z.string().email("Invalid email address"),
  phoneNumber: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, "Phone must be in E.164 format (e.g. +251912345678)")
    .optional()
    .or(z.literal("")),
})

export type UpdateProfileInput = z.infer<typeof updateProfileSchema>

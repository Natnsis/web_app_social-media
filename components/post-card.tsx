"use client"

import { useState } from "react"
import Image from "next/image"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Heart as HeartOutline, MessageSquare, Bookmark as BookmarkOutline, CornerUpRight, Eye, CirclePlay } from "nasicon-react/outline"
import { DotsHorizontal, Heart as HeartSolid, Bookmark as BookmarkSolid } from "nasicon-react/solid"
import type { Post } from "@/types"

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

interface PostCardProps {
  post: Post
  isLiked?: boolean
  isSaved?: boolean
  onLike?: (id: string) => void
  onSave?: (id: string) => void
  onComment?: (id: string) => void
  onShare?: (id: string) => void
  featured?: boolean
}

export function PostCard({
  post,
  isLiked = false,
  isSaved = false,
  onLike,
  onSave,
  onComment,
  onShare,
  featured = false,
}: PostCardProps) {
  const [imgError, setImgError] = useState<Set<string>>(new Set())

  const hasImages = post.files.some((f) => f.mediaType === "image")
  const hasVideos = post.files.some((f) => f.mediaType === "video")
  const images = post.files.filter((f) => f.mediaType === "image")
  const videos = post.files.filter((f) => f.mediaType === "video")

  return (
    <article className="overflow-hidden rounded-2xl border border-border bg-card">
      <div className="p-4 sm:p-5">
        <div className="flex items-start justify-between gap-4">
          <div className="flex items-center gap-3">
            <Avatar className="size-11">
              <AvatarFallback className="bg-primary/15 text-primary text-sm font-bold">
                {getInitials(post.church.name)}
              </AvatarFallback>
            </Avatar>
            <div>
              <p className="font-bold leading-tight">{post.church.name}</p>
              <p className="text-xs text-muted-foreground">{post.timeAgo}</p>
            </div>
          </div>
          <Button variant="ghost" size="icon-sm" className="rounded-lg">
            <DotsHorizontal size={20} />
          </Button>
        </div>

        {post.title && (
          <h3 className="mt-3 text-lg font-bold">{post.title}</h3>
        )}

        <p className="mt-2 text-[15px] leading-relaxed">{post.content}</p>

        {post.isTagged && (
          <div className="mt-2 flex flex-wrap gap-2">
            <Badge variant="outline" className="rounded-full text-primary border-primary/30 text-[11px]">
              Tagged
            </Badge>
          </div>
        )}
      </div>

      {/* Media */}
      {(hasImages || hasVideos) && (
        <div className="px-4 sm:px-5">
          {featured && images.length > 0 ? (
            <div className="relative aspect-[16/9] overflow-hidden rounded-xl bg-muted">
              <Image
                src={images[0].novaUrl ?? ""}
                alt={images[0].name}
                fill
                className="object-cover"
                sizes="(min-width: 1024px) 680px, 100vw"
                unoptimized
                onError={() => setImgError((prev) => new Set(prev).add(images[0].id))}
              />
              {imgError.has(images[0].id) && (
                <div className="flex h-full items-center justify-center bg-muted text-muted-foreground text-sm">
                  Image unavailable
                </div>
              )}
              <div className="absolute inset-0 bg-gradient-to-t from-black/45 via-black/5 to-transparent" />
              <div className="absolute bottom-4 left-4 rounded-lg bg-background/90 px-3 py-1 text-xs font-bold backdrop-blur">
                Church highlight
              </div>
            </div>
          ) : images.length === 1 ? (
            <div className="relative aspect-video overflow-hidden rounded-xl bg-muted">
              <Image
                src={images[0].novaUrl ?? ""}
                alt={images[0].name}
                fill
                className="object-cover"
                sizes="(min-width: 1024px) 680px, 100vw"
                unoptimized
                onError={() => setImgError((prev) => new Set(prev).add(images[0].id))}
              />
              {imgError.has(images[0].id) && (
                <div className="flex h-full items-center justify-center bg-muted text-muted-foreground text-sm">
                  Image unavailable
                </div>
              )}
            </div>
          ) : images.length > 1 ? (
            <div className="grid grid-cols-2 gap-2">
              {images.slice(0, 4).map((file) => (
                <div key={file.id} className="relative aspect-square overflow-hidden rounded-xl bg-muted">
                  <Image
                    src={file.novaUrl ?? ""}
                    alt={file.name}
                    fill
                    className="object-cover"
                    sizes="(max-width: 768px) 50vw, 320px"
                    unoptimized
                    onError={() => setImgError((prev) => new Set(prev).add(file.id))}
                  />
                  {imgError.has(file.id) && (
                    <div className="flex h-full items-center justify-center bg-muted text-muted-foreground text-xs">
                      Unavailable
                    </div>
                  )}
                </div>
              ))}
              {images.length > 4 && (
                <div className="relative flex aspect-square items-center justify-center rounded-xl bg-muted text-lg font-bold text-muted-foreground">
                  +{images.length - 4}
                </div>
              )}
            </div>
          ) : null}

          {videos.length > 0 && (
            <div className={`mt-2 grid gap-2 ${videos.length === 1 ? "grid-cols-1" : "grid-cols-2"}`}>
              {videos.map((file) => (
                <div
                  key={file.id}
                  className="relative aspect-video flex items-center justify-center rounded-xl bg-gray-800 cursor-pointer"
                >
                  {file.isReady ? (
                    <>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <div className="flex size-14 items-center justify-center rounded-full bg-primary/90 shadow-lg">
                          <CirclePlay size={30} className="text-white" />
                        </div>
                      </div>
                      <div className="absolute bottom-2 right-2 rounded bg-black/60 px-2 py-0.5 text-xs text-white">
                        {file.videoStatus === "ready" ? "Ready" : "Processing"}
                      </div>
                    </>
                  ) : (
                    <div className="flex flex-col items-center gap-2 text-white">
                      <div className="flex size-12 items-center justify-center rounded-full bg-white/20">
                        <CirclePlay size={24} />
                      </div>
                      <span className="text-xs">Processing...</span>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Action bar */}
      <div className="flex items-center justify-between px-5 py-4">
        <div className="flex items-center gap-5">
          <button
            onClick={() => onLike?.(post.id)}
            className={`flex items-center gap-2 text-sm font-semibold transition-colors ${
              isLiked ? "text-red-500" : "text-muted-foreground hover:text-red-500"
            }`}
          >
            {isLiked ? <HeartSolid size={19} /> : <HeartOutline size={19} />}
            <span>{post._count.likes}</span>
          </button>
          <button
            onClick={() => onComment?.(post.id)}
            className="flex items-center gap-2 text-sm font-semibold text-muted-foreground transition-colors hover:text-primary"
          >
            <MessageSquare size={19} />
            <span>{post._count.comments}</span>
          </button>
          {post._count.saves > 0 && (
            <span className="flex items-center gap-2 text-sm font-semibold text-muted-foreground">
              <Eye size={19} />
              <span>{post._count.saves}</span>
            </span>
          )}
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => onSave?.(post.id)}
            className={`rounded-lg p-2 transition-colors ${
              isSaved
                ? "text-primary"
                : "text-muted-foreground hover:text-primary"
            }`}
          >
            {isSaved ? <BookmarkSolid size={18} /> : <BookmarkOutline size={18} />}
          </button>
          <button
            onClick={() => onShare?.(post.id)}
            className="rounded-lg p-2 text-muted-foreground transition-colors hover:text-primary"
          >
            <CornerUpRight size={18} />
          </button>
        </div>
      </div>
    </article>
  )
}

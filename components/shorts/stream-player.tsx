"use client"

import { forwardRef } from "react"
import { StreamPlayerWrapper as BaseStreamPlayer, type StreamPlayerHandle } from "@/components/stream-player"
import type { Short } from "@/types"

export type { StreamPlayerHandle }

interface StreamPlayerWrapperProps {
  short: Short
  playing?: boolean
}

export const StreamPlayerWrapper = forwardRef<StreamPlayerHandle, StreamPlayerWrapperProps>(
  function StreamPlayerWrapper({ short, playing = false }, ref) {
    const nova = short.novaFile

    if (!nova?.appId || !nova?.streamCode) {
      return (
        <div className="relative h-full w-full">
          <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-b from-gray-900 to-gray-800">
            <div className="flex flex-col items-center gap-2 px-4 text-center">
              <p className="text-sm font-medium text-white/80">Video unavailable</p>
              <p className="text-xs text-white/50">This short may still be processing</p>
            </div>
          </div>
        </div>
      )
    }

    return (
      <BaseStreamPlayer
        ref={ref}
        id={short.id}
        appId={nova.appId}
        streamCode={nova.streamCode}
        playing={playing}
      />
    )
  }
)

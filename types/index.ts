export interface PostFile {
  id: string
  novaFileId: string | null
  novaVideoId: string | null
  name: string
  mimeType: string
  size: number
  novaUrl: string | null
  mediaType: "image" | "video"
  streamCode: string | null
  appId: string | null
  isReady: boolean | null
  videoStatus: string | null
}

export interface ChurchInfo {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface PostCount {
  comments: number
  likes: number
  saves: number
}

export interface Post {
  id: string
  churchId: string
  title: string | null
  content: string
  status: string
  mediaUrls: string | null
  novaFileIds: string[]
  isTagged: boolean
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  church: ChurchInfo
  _count: PostCount
  timeAgo: string
  files: PostFile[]
}

export interface PostsMeta {
  page: number
  limit: number
  total: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

export interface PostsResponse {
  success: boolean
  data: Post[]
  meta: PostsMeta
  timestamp: string
}

export interface PlayVideo {
  fileId: string
  name: string
  isReady: boolean
  appId: string
  streamCode: string
  novaVideoId: string
  duration: number
}

export interface PlayPostResponse {
  postId: string
  videos: PlayVideo[]
}

export interface Comment {
  id: string
  body: string
  media: string | null
  parentId: string | null
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  author: {
    id: string
    name: string
    initials: string
    avatarUrl: string | null
  }
  _count: {
    replies: number
  }
  replies?: Comment[]
}

export interface CommentsResponse {
  success: boolean
  data: Comment[]
  meta: PostsMeta
  timestamp: string
}

export interface CreatePostPayload {
  title?: string
  content: string
  novaFileIds?: string[]
  allowComments?: boolean
}

export interface CreateCommentPayload {
  body: string
  parentId?: string
  media?: string
}

export interface ApiResponse<T = unknown> {
  success: boolean
  data: T
  message?: string
  timestamp?: string
}

export interface CreatePostResponse {
  success: boolean
  data: Post
  timestamp: string
}

/**
 * 通知服务
 *
 * 处理通知相关API调用
 */

import api from './api'
import type { ApiResponse, PaginatedData } from '@/types'

/**
 * 通知
 */
export interface Notification {
    /** 通知ID */
    id: string
    /** 通知标题 */
    title: string
    /** 通知内容 */
    content: string
    /** 通知类型 */
    type: 'APPROVAL' | 'SYSTEM' | 'REMINDER'
    /** 关联业务ID */
    relatedId?: string
    /** 是否已读 */
    isRead: boolean
    /** 阅读时间 */
    readAt?: string
    /** 创建时间 */
    createdAt: string
}

/**
 * 获取通知列表
 *
 * @param page 页码
 * @param pageSize 每页条数
 * @param isRead 是否已读筛选（可选）
 * @returns 分页结果
 */
export async function getNotifications(
    page: number = 1,
    pageSize: number = 10,
    isRead?: boolean
): Promise<PaginatedData<Notification>> {
    const params: Record<string, unknown> = { page, pageSize }
    if (isRead !== undefined) {
        params.isRead = isRead
    }
    const response = await api.get<ApiResponse<PaginatedData<Notification>>>('/v1/notifications', { params })
    return response.data.data
}

/**
 * 标记单条通知为已读
 *
 * @param id 通知ID
 */
export async function markAsRead(id: string): Promise<void> {
    await api.put<ApiResponse<void>>(`/v1/notifications/${id}/read`)
}

/**
 * 标记所有通知为已读
 */
export async function markAllAsRead(): Promise<void> {
    await api.put<ApiResponse<void>>('/v1/notifications/read-all')
}

/**
 * 获取未读通知数量
 *
 * @returns 未读数量
 */
export async function getUnreadCount(): Promise<number> {
    const response = await api.get<ApiResponse<{ count: number }>>('/v1/notifications/unread-count')
    return response.data.data.count
}

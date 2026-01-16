/**
 * 职位服务
 *
 * 提供职位相关 API 调用
 */

import api from './api'

/**
 * 职位信息接口
 */
export interface Position {
    /** 职位ID */
    id: number
    /** 职位编码 */
    code: string
    /** 职位名称 */
    name: string
    /** 职位描述 */
    description: string | null
    /** 职级 */
    level: number | null
    /** 状态: 0-禁用 1-启用 */
    status: number
    /** 排序序号 */
    sortOrder: number | null
}

/**
 * API响应包装
 */
interface ApiResponse<T> {
    code: number
    message: string
    data: T
    timestamp: number
}

/**
 * 获取所有职位列表
 *
 * @returns 职位列表
 */
export async function getAllPositions(): Promise<Position[]> {
    const response = await api.get<ApiResponse<Position[]>>('/v1/positions')
    return response.data.data
}

import api from './api'

/**
 * 仪表盘统计数据类型
 */
export interface DashboardStatistics {
    /** 待处理审批数量 */
    pending: number
    /** 已通过审批数量 */
    approved: number
    /** 已拒绝审批数量 */
    rejected: number
    /** 总审批数量 */
    total: number
}

/**
 * 最近活动类型
 */
export interface RecentActivity {
    /** 审批ID */
    approvalId: string
    /** 活动类型 */
    activityType: 'created' | 'approved' | 'rejected' | 'withdrawn'
    /** 审批标题 */
    title: string
    /** 审批类型名称 */
    typeName: string
    /** 审批类型图标 */
    typeIcon?: string
    /** 审批类型颜色 */
    typeColor?: string
    /** 活动时间 */
    activityTime: string
    /** 状态码 */
    status: number
    /** 相对时间描述 */
    relativeTime: string
}

/**
 * 仪表盘服务
 */
const dashboardService = {
    /**
     * 获取仪表盘统计数据
     * 
     * @returns 统计数据
     */
    getStatistics: async (): Promise<DashboardStatistics> => {
        const response = await api.get<{ data: DashboardStatistics }>('/dashboard/statistics')
        return response.data.data
    },

    /**
     * 获取最近活动记录
     * 
     * @param limit 返回数量限制
     * @returns 最近活动列表
     */
    getRecentActivities: async (limit: number = 10): Promise<RecentActivity[]> => {
        const response = await api.get<{ data: RecentActivity[] }>('/dashboard/recent-activities', {
            params: { limit }
        })
        return response.data.data
    },
}

export default dashboardService

/**
 * 工作流服务
 *
 * 处理工作流配置相关API调用
 */

import api from './api'
import type { ApiResponse, PaginatedData } from '@/types'

/**
 * 工作流节点
 */
export interface WorkflowNode {
    /** 节点ID */
    id?: number
    /** 节点名称 */
    nodeName: string
    /** 节点顺序 */
    nodeOrder: number
    /** 审批人类型 */
    approverType: 'USER' | 'POSITION' | 'DEPARTMENT_HEAD'
    /** 审批人/职位ID */
    approverId?: number
    /** 审批人/职位名称 */
    approverName?: string
}

/**
 * 工作流模板
 */
export interface Workflow {
    /** 模板ID */
    id: number
    /** 模板名称 */
    name: string
    /** 关联审批类型编码 */
    typeCode: string
    /** 审批类型名称 */
    typeName?: string
    /** 模板描述 */
    description?: string
    /** 状态 */
    status: number
    /** 节点数量 */
    nodeCount?: number
    /** 创建人ID */
    createdBy?: number
    /** 创建人名称 */
    createdByName?: string
    /** 创建时间 */
    createdAt?: string
    /** 更新时间 */
    updatedAt?: string
    /** 节点列表 */
    nodes?: WorkflowNode[]
}

/**
 * 创建工作流请求
 */
export interface CreateWorkflowRequest {
    /** 模板名称 */
    name: string
    /** 关联审批类型编码 */
    typeCode: string
    /** 模板描述 */
    description?: string
    /** 状态 */
    status?: number
    /** 节点列表 */
    nodes: WorkflowNode[]
}

/**
 * 更新工作流请求
 */
export interface UpdateWorkflowRequest {
    /** 模板名称 */
    name: string
    /** 模板描述 */
    description?: string
    /** 状态 */
    status?: number
    /** 节点列表 */
    nodes: WorkflowNode[]
}

/**
 * 获取工作流列表
 *
 * @param page 页码
 * @param pageSize 每页条数
 * @param typeCode 类型编码筛选（可选）
 * @param status 状态筛选（可选）
 * @returns 分页结果
 */
export async function getWorkflows(
    page: number = 1,
    pageSize: number = 10,
    typeCode?: string,
    status?: number
): Promise<PaginatedData<Workflow>> {
    const params: Record<string, unknown> = { page, pageSize }
    if (typeCode) {
        params.typeCode = typeCode
    }
    if (status !== undefined) {
        params.status = status
    }
    const response = await api.get<ApiResponse<PaginatedData<Workflow>>>('/v1/workflows', { params })
    return response.data.data
}

/**
 * 获取工作流详情
 *
 * @param id 工作流ID
 * @returns 工作流详情
 */
export async function getWorkflowDetail(id: number): Promise<Workflow> {
    const response = await api.get<ApiResponse<Workflow>>(`/v1/workflows/${id}`)
    return response.data.data
}

/**
 * 根据类型编码获取工作流
 *
 * @param typeCode 审批类型编码
 * @returns 工作流详情
 */
export async function getWorkflowByTypeCode(typeCode: string): Promise<Workflow | null> {
    const response = await api.get<ApiResponse<Workflow>>('/v1/workflows/by-type', {
        params: { typeCode }
    })
    return response.data.data
}

/**
 * 创建工作流
 *
 * @param data 创建请求
 * @returns 工作流信息
 */
export async function createWorkflow(data: CreateWorkflowRequest): Promise<Workflow> {
    const response = await api.post<ApiResponse<Workflow>>('/v1/workflows', data)
    return response.data.data
}

/**
 * 更新工作流
 *
 * @param id 工作流ID
 * @param data 更新请求
 * @returns 工作流信息
 */
export async function updateWorkflow(id: number, data: UpdateWorkflowRequest): Promise<Workflow> {
    const response = await api.put<ApiResponse<Workflow>>(`/v1/workflows/${id}`, data)
    return response.data.data
}

/**
 * 删除工作流
 *
 * @param id 工作流ID
 */
export async function deleteWorkflow(id: number): Promise<void> {
    await api.delete<ApiResponse<void>>(`/v1/workflows/${id}`)
}

/**
 * 更新工作流状态
 *
 * @param id 工作流ID
 * @param status 状态: 0-禁用 1-启用
 */
export async function updateWorkflowStatus(id: number, status: number): Promise<void> {
    await api.put<ApiResponse<void>>(`/v1/workflows/${id}/status`, { status })
}

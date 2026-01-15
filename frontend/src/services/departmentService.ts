/**
 * 部门管理 API 服务
 *
 * 提供部门CRUD和树形结构查询的API调用
 */

import api from './api';

/**
 * 部门基础信息接口
 */
export interface Department {
    /** 部门ID */
    id: number;
    /** 部门名称 */
    name: string;
    /** 父部门ID */
    parentId: number;
    /** 部门负责人ID */
    leaderId: number | null;
    /** 排序序号 */
    sortOrder: number;
    /** 状态: 0-禁用 1-启用 */
    status: number;
    /** 创建时间 */
    createdAt: string;
    /** 更新时间 */
    updatedAt: string;
}

/**
 * 部门树形结构接口
 */
export interface DepartmentTree extends Department {
    /** 负责人姓名 */
    leaderName: string | null;
    /** 子部门列表 */
    children: DepartmentTree[];
}

/**
 * 创建/更新部门请求参数
 */
export interface DepartmentRequest {
    /** 部门名称 */
    name: string;
    /** 父部门ID */
    parentId?: number;
    /** 部门负责人ID */
    leaderId?: number | null;
    /** 排序序号 */
    sortOrder?: number;
    /** 状态 */
    status?: number;
}

/**
 * 简单用户信息（用于负责人选择）
 */
export interface SimpleUser {
    /** 用户ID */
    id: number;
    /** 用户名 */
    username: string;
    /** 昵称 */
    nickname: string;
}

/**
 * API响应包装
 */
interface ApiResponse<T> {
    code: number;
    message: string;
    data: T;
    timestamp: number;
}

/**
 * 获取部门树形结构
 *
 * @returns 部门树形结构数组
 */
export async function getDepartmentTree(): Promise<DepartmentTree[]> {
    const response = await api.get<ApiResponse<DepartmentTree[]>>('/departments/tree');
    return response.data.data;
}

/**
 * 获取所有部门列表（平铺）
 *
 * @returns 部门列表
 */
export async function getAllDepartments(): Promise<Department[]> {
    const response = await api.get<ApiResponse<Department[]>>('/departments');
    return response.data.data;
}

/**
 * 获取部门详情
 *
 * @param id 部门ID
 * @returns 部门详情
 */
export async function getDepartmentById(id: number): Promise<Department> {
    const response = await api.get<ApiResponse<Department>>(`/departments/${id}`);
    return response.data.data;
}

/**
 * 创建部门
 *
 * @param data 部门信息
 * @returns 创建的部门
 */
export async function createDepartment(data: DepartmentRequest): Promise<Department> {
    const response = await api.post<ApiResponse<Department>>('/departments', data);
    return response.data.data;
}

/**
 * 更新部门
 *
 * @param id 部门ID
 * @param data 部门信息
 * @returns 更新后的部门
 */
export async function updateDepartment(id: number, data: DepartmentRequest): Promise<Department> {
    const response = await api.put<ApiResponse<Department>>(`/departments/${id}`, data);
    return response.data.data;
}

/**
 * 删除部门
 *
 * @param id 部门ID
 */
export async function deleteDepartment(id: number): Promise<void> {
    await api.delete(`/departments/${id}`);
}

/**
 * 获取所有用户列表（用于选择负责人）
 *
 * @returns 用户列表
 */
export async function getAllUsers(): Promise<SimpleUser[]> {
    const response = await api.get<ApiResponse<SimpleUser[]>>('/users');
    return response.data.data;
}

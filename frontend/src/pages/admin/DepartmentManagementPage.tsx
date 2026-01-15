/**
 * 部门管理页面
 *
 * 仅管理员可访问，提供部门树形展示和CRUD操作
 */

import { useState, useEffect, useCallback } from 'react';
import { Plus, RefreshCw, Building2 } from 'lucide-react';
import { toast } from 'sonner';

import { PageContainer } from '@/components/layout/PageContainer';
import { Button } from '@/components/ui/button';
import { DepartmentTreeComponent } from '@/components/business/DepartmentTree';
import { DepartmentDialog } from '@/components/business/DepartmentDialog';
import {
    getDepartmentTree,
    getAllDepartments,
    createDepartment,
    updateDepartment,
    deleteDepartment,
    type DepartmentTree,
    type Department,
    type DepartmentRequest,
    type SimpleUser,
} from '@/services/departmentService';

/**
 * 模拟用户数据（TODO: 待接入真实用户API）
 */
const mockUsers: SimpleUser[] = [
    { id: 1, username: 'admin', nickname: '系统管理员' },
    { id: 2, username: 'hr_admin', nickname: '人事经理' },
    { id: 3, username: 'tech_lead', nickname: '技术总监' },
    { id: 4, username: 'finance_mgr', nickname: '财务经理' },
    { id: 5, username: 'dev_zhang', nickname: '张开发' },
    { id: 6, username: 'market_li', nickname: '李市场' },
];

/**
 * 部门管理页面组件
 */
export default function DepartmentManagementPage() {
    // 部门树数据
    const [treeData, setTreeData] = useState<DepartmentTree[]>([]);
    // 所有部门列表（平铺）
    const [allDepartments, setAllDepartments] = useState<Department[]>([]);
    // 用户列表
    const [users] = useState<SimpleUser[]>(mockUsers);
    // 加载状态
    const [loading, setLoading] = useState(true);
    // 当前选中的部门
    const [selectedDepartment, setSelectedDepartment] = useState<DepartmentTree | null>(null);
    // 对话框状态
    const [dialogOpen, setDialogOpen] = useState(false);
    // 编辑模式时的部门
    const [editingDepartment, setEditingDepartment] = useState<DepartmentTree | null>(null);
    // 新增子部门时的父部门
    const [parentDepartment, setParentDepartment] = useState<DepartmentTree | null>(null);

    /**
     * 加载部门数据
     */
    const loadData = useCallback(async () => {
        setLoading(true);
        try {
            const [tree, departments] = await Promise.all([
                getDepartmentTree(),
                getAllDepartments(),
            ]);
            setTreeData(tree);
            setAllDepartments(departments);
        } catch (error) {
            console.error('加载部门数据失败:', error);
            toast.error('加载部门数据失败');
        } finally {
            setLoading(false);
        }
    }, []);

    // 初始加载
    useEffect(() => {
        loadData();
    }, [loadData]);

    /**
     * 处理新增顶级部门
     */
    const handleAddRoot = () => {
        setEditingDepartment(null);
        setParentDepartment(null);
        setDialogOpen(true);
    };

    /**
     * 处理新增子部门
     */
    const handleAddChild = (parent: DepartmentTree) => {
        setEditingDepartment(null);
        setParentDepartment(parent);
        setDialogOpen(true);
    };

    /**
     * 处理编辑部门
     */
    const handleEdit = (department: DepartmentTree) => {
        setEditingDepartment(department);
        setParentDepartment(null);
        setDialogOpen(true);
    };

    /**
     * 处理删除部门
     */
    const handleDelete = async (department: DepartmentTree) => {
        // 确认删除
        if (!window.confirm(`确定要删除部门"${department.name}"吗？此操作不可撤销。`)) {
            return;
        }

        try {
            await deleteDepartment(department.id);
            toast.success('部门删除成功');
            await loadData();
            // 如果删除的是当前选中的部门，清除选中状态
            if (selectedDepartment?.id === department.id) {
                setSelectedDepartment(null);
            }
        } catch (error: unknown) {
            console.error('删除部门失败:', error);
            const errorMessage = error instanceof Error ? error.message : '删除部门失败';
            toast.error(errorMessage);
        }
    };

    /**
     * 处理保存部门
     */
    const handleSave = async (data: DepartmentRequest) => {
        try {
            if (editingDepartment) {
                // 更新模式
                await updateDepartment(editingDepartment.id, data);
                toast.success('部门更新成功');
            } else {
                // 新增模式
                await createDepartment(data);
                toast.success('部门创建成功');
            }
            await loadData();
        } catch (error: unknown) {
            console.error('保存部门失败:', error);
            const errorMessage = error instanceof Error ? error.message : '保存部门失败';
            toast.error(errorMessage);
            throw error; // 抛出让对话框处理
        }
    };

    return (
        <PageContainer
            title="部门管理"
            description="管理组织架构，配置部门结构和负责人。"
            action={
                <div className="flex gap-2">
                    <Button
                        variant="outline"
                        onClick={loadData}
                        disabled={loading}
                        className="clickable"
                    >
                        <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                        刷新
                    </Button>
                    <Button onClick={handleAddRoot} className="clickable">
                        <Plus className="h-4 w-4 mr-2" />
                        新增部门
                    </Button>
                </div>
            }
        >
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* 部门树区域 */}
                <div className="lg:col-span-2">
                    <div className="interactive-card p-4">
                        <div className="flex items-center gap-2 mb-4 pb-4 border-b">
                            <Building2 className="h-5 w-5 text-primary" />
                            <h2 className="font-semibold">组织架构</h2>
                        </div>
                        {loading ? (
                            <div className="flex items-center justify-center py-12">
                                <RefreshCw className="h-8 w-8 animate-spin text-muted-foreground" />
                            </div>
                        ) : (
                            <DepartmentTreeComponent
                                data={treeData}
                                selectedId={selectedDepartment?.id}
                                onSelect={setSelectedDepartment}
                                onAddChild={handleAddChild}
                                onEdit={handleEdit}
                                onDelete={handleDelete}
                            />
                        )}
                    </div>
                </div>

                {/* 部门详情区域 */}
                <div className="lg:col-span-1">
                    <div className="interactive-card p-4 sticky top-6">
                        <h2 className="font-semibold mb-4 pb-4 border-b">部门详情</h2>
                        {selectedDepartment ? (
                            <div className="space-y-4">
                                <div>
                                    <label className="text-sm text-muted-foreground">部门名称</label>
                                    <p className="font-medium">{selectedDepartment.name}</p>
                                </div>
                                <div>
                                    <label className="text-sm text-muted-foreground">部门负责人</label>
                                    <p className="font-medium">
                                        {selectedDepartment.leaderName || '暂无'}
                                    </p>
                                </div>
                                <div>
                                    <label className="text-sm text-muted-foreground">排序序号</label>
                                    <p className="font-medium">{selectedDepartment.sortOrder}</p>
                                </div>
                                <div>
                                    <label className="text-sm text-muted-foreground">状态</label>
                                    <p className="font-medium">
                                        {selectedDepartment.status === 1 ? (
                                            <span className="text-green-600">启用</span>
                                        ) : (
                                            <span className="text-destructive">禁用</span>
                                        )}
                                    </p>
                                </div>
                                <div>
                                    <label className="text-sm text-muted-foreground">子部门数量</label>
                                    <p className="font-medium">
                                        {selectedDepartment.children?.length || 0} 个
                                    </p>
                                </div>
                                <div className="pt-4 flex gap-2">
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        className="flex-1 clickable"
                                        onClick={() => handleEdit(selectedDepartment)}
                                    >
                                        编辑
                                    </Button>
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        className="flex-1 clickable"
                                        onClick={() => handleAddChild(selectedDepartment)}
                                    >
                                        新增子部门
                                    </Button>
                                </div>
                            </div>
                        ) : (
                            <div className="text-center py-8 text-muted-foreground">
                                <Building2 className="h-12 w-12 mx-auto mb-4 opacity-30" />
                                <p>选择一个部门查看详情</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* 部门编辑对话框 */}
            <DepartmentDialog
                open={dialogOpen}
                onOpenChange={setDialogOpen}
                department={editingDepartment}
                parentDepartment={parentDepartment}
                allDepartments={allDepartments}
                users={users}
                onSave={handleSave}
                isLoading={loading}
            />
        </PageContainer>
    );
}

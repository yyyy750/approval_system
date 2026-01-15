/**
 * 部门树形组件
 *
 * 递归展示部门层级结构，支持展开/折叠和选择操作
 */

import { useState } from 'react';
import { ChevronRight, ChevronDown, Building2, User, MoreHorizontal, Plus, Pencil, Trash2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import type { DepartmentTree } from '@/services/departmentService';

interface DepartmentTreeProps {
    /** 部门树数据 */
    data: DepartmentTree[];
    /** 当前选中的部门ID */
    selectedId?: number;
    /** 部门选中回调 */
    onSelect?: (department: DepartmentTree) => void;
    /** 新增子部门回调 */
    onAddChild?: (parentDepartment: DepartmentTree) => void;
    /** 编辑部门回调 */
    onEdit?: (department: DepartmentTree) => void;
    /** 删除部门回调 */
    onDelete?: (department: DepartmentTree) => void;
    /** 根节点层级 */
    level?: number;
}

interface DepartmentNodeProps {
    /** 部门节点数据 */
    node: DepartmentTree;
    /** 层级深度 */
    level: number;
    /** 当前选中的部门ID */
    selectedId?: number;
    /** 部门选中回调 */
    onSelect?: (department: DepartmentTree) => void;
    /** 新增子部门回调 */
    onAddChild?: (parentDepartment: DepartmentTree) => void;
    /** 编辑部门回调 */
    onEdit?: (department: DepartmentTree) => void;
    /** 删除部门回调 */
    onDelete?: (department: DepartmentTree) => void;
}

/**
 * 单个部门节点组件
 */
function DepartmentNode({
    node,
    level,
    selectedId,
    onSelect,
    onAddChild,
    onEdit,
    onDelete,
}: DepartmentNodeProps) {
    const [isExpanded, setIsExpanded] = useState(true);
    const hasChildren = node.children && node.children.length > 0;
    const isSelected = selectedId === node.id;

    return (
        <div className="select-none">
            {/* 节点行 */}
            <div
                className={cn(
                    'group flex items-center gap-2 px-2 py-2 rounded-lg transition-all duration-200 cursor-pointer',
                    isSelected
                        ? 'bg-primary/10 text-primary border border-primary/20'
                        : 'hover:bg-muted/50 border border-transparent'
                )}
                style={{ paddingLeft: `${level * 20 + 8}px` }}
                onClick={() => onSelect?.(node)}
            >
                {/* 展开/折叠按钮 */}
                <button
                    className={cn(
                        'p-0.5 rounded hover:bg-muted transition-colors',
                        !hasChildren && 'invisible'
                    )}
                    onClick={(e) => {
                        e.stopPropagation();
                        setIsExpanded(!isExpanded);
                    }}
                >
                    {isExpanded ? (
                        <ChevronDown className="h-4 w-4 text-muted-foreground" />
                    ) : (
                        <ChevronRight className="h-4 w-4 text-muted-foreground" />
                    )}
                </button>

                {/* 部门图标 */}
                <Building2 className={cn(
                    'h-4 w-4 shrink-0',
                    isSelected ? 'text-primary' : 'text-muted-foreground'
                )} />

                {/* 部门名称 */}
                <span className="flex-1 font-medium truncate">{node.name}</span>

                {/* 负责人标签 */}
                {node.leaderName && (
                    <span className="flex items-center gap-1 text-xs text-muted-foreground bg-muted/50 px-2 py-0.5 rounded-full">
                        <User className="h-3 w-3" />
                        {node.leaderName}
                    </span>
                )}

                {/* 状态标签 */}
                {node.status === 0 && (
                    <span className="text-xs text-destructive bg-destructive/10 px-2 py-0.5 rounded-full">
                        已禁用
                    </span>
                )}

                {/* 操作菜单 */}
                <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                        <Button
                            variant="ghost"
                            size="sm"
                            className="h-7 w-7 p-0 opacity-0 group-hover:opacity-100 transition-opacity"
                            onClick={(e) => e.stopPropagation()}
                        >
                            <MoreHorizontal className="h-4 w-4" />
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="w-40">
                        <DropdownMenuItem onClick={() => onAddChild?.(node)}>
                            <Plus className="h-4 w-4 mr-2" />
                            新增子部门
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => onEdit?.(node)}>
                            <Pencil className="h-4 w-4 mr-2" />
                            编辑
                        </DropdownMenuItem>
                        <DropdownMenuItem
                            className="text-destructive focus:text-destructive"
                            onClick={() => onDelete?.(node)}
                        >
                            <Trash2 className="h-4 w-4 mr-2" />
                            删除
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>

            {/* 子节点 */}
            {hasChildren && isExpanded && (
                <div className="animate-in slide-in-from-top-2 duration-200">
                    {node.children.map((child) => (
                        <DepartmentNode
                            key={child.id}
                            node={child}
                            level={level + 1}
                            selectedId={selectedId}
                            onSelect={onSelect}
                            onAddChild={onAddChild}
                            onEdit={onEdit}
                            onDelete={onDelete}
                        />
                    ))}
                </div>
            )}
        </div>
    );
}

/**
 * 部门树形组件
 *
 * @param data 部门树数据
 * @param selectedId 当前选中的部门ID
 * @param onSelect 部门选中回调
 * @param onAddChild 新增子部门回调
 * @param onEdit 编辑部门回调
 * @param onDelete 删除部门回调
 * @param level 根节点层级
 */
export function DepartmentTreeComponent({
    data,
    selectedId,
    onSelect,
    onAddChild,
    onEdit,
    onDelete,
    level = 0,
}: DepartmentTreeProps) {
    if (!data || data.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center py-12 text-muted-foreground">
                <Building2 className="h-12 w-12 mb-4 opacity-50" />
                <p>暂无部门数据</p>
            </div>
        );
    }

    return (
        <div className="space-y-1">
            {data.map((node) => (
                <DepartmentNode
                    key={node.id}
                    node={node}
                    level={level}
                    selectedId={selectedId}
                    onSelect={onSelect}
                    onAddChild={onAddChild}
                    onEdit={onEdit}
                    onDelete={onDelete}
                />
            ))}
        </div>
    );
}

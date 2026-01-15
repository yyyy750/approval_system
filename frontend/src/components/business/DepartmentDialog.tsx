/**
 * 部门编辑对话框组件
 *
 * 用于新增和编辑部门信息，包括名称、上级部门和负责人选择
 */

import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { Loader2 } from 'lucide-react';

import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import type { DepartmentTree, DepartmentRequest, SimpleUser, Department } from '@/services/departmentService';

/**
 * 表单验证规则
 */
const formSchema = z.object({
    name: z.string().min(1, '部门名称不能为空').max(100, '部门名称不能超过100个字符'),
    parentId: z.number().optional(),
    leaderId: z.number().nullable().optional(),
    sortOrder: z.number().min(0).optional(),
    status: z.number().min(0).max(1).optional(),
});

type FormData = z.infer<typeof formSchema>;

interface DepartmentDialogProps {
    /** 对话框是否打开 */
    open: boolean;
    /** 关闭对话框回调 */
    onOpenChange: (open: boolean) => void;
    /** 编辑模式时的部门数据 */
    department?: DepartmentTree | null;
    /** 新增子部门时的父部门 */
    parentDepartment?: DepartmentTree | null;
    /** 所有部门列表（用于选择上级部门） */
    allDepartments: Department[];
    /** 所有用户列表（用于选择负责人） */
    users: SimpleUser[];
    /** 保存成功回调 */
    onSave: (data: DepartmentRequest) => Promise<void>;
    /** 是否正在加载 */
    isLoading?: boolean;
}

/**
 * 部门编辑对话框
 *
 * @param open 对话框是否打开
 * @param onOpenChange 关闭对话框回调
 * @param department 编辑模式时的部门数据
 * @param parentDepartment 新增子部门时的父部门
 * @param allDepartments 所有部门列表
 * @param users 所有用户列表
 * @param onSave 保存成功回调
 * @param isLoading 是否正在加载
 */
export function DepartmentDialog({
    open,
    onOpenChange,
    department,
    parentDepartment,
    allDepartments,
    users,
    onSave,
    isLoading = false,
}: DepartmentDialogProps) {
    const [submitting, setSubmitting] = useState(false);
    const isEditMode = !!department;

    const {
        register,
        handleSubmit,
        reset,
        setValue,
        watch,
        formState: { errors },
    } = useForm<FormData>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            name: '',
            parentId: 0,
            leaderId: null,
            sortOrder: 0,
            status: 1,
        },
    });

    const watchedParentId = watch('parentId');
    const watchedLeaderId = watch('leaderId');

    // 对话框打开时重置表单
    useEffect(() => {
        if (open) {
            if (department) {
                // 编辑模式
                reset({
                    name: department.name,
                    parentId: department.parentId || 0,
                    leaderId: department.leaderId || null,
                    sortOrder: department.sortOrder || 0,
                    status: department.status ?? 1,
                });
            } else if (parentDepartment) {
                // 新增子部门模式
                reset({
                    name: '',
                    parentId: parentDepartment.id,
                    leaderId: null,
                    sortOrder: 0,
                    status: 1,
                });
            } else {
                // 新增顶级部门模式
                reset({
                    name: '',
                    parentId: 0,
                    leaderId: null,
                    sortOrder: 0,
                    status: 1,
                });
            }
        }
    }, [open, department, parentDepartment, reset]);

    /**
     * 表单提交处理
     */
    const onSubmit = async (data: FormData) => {
        setSubmitting(true);
        try {
            await onSave({
                name: data.name,
                parentId: data.parentId || 0,
                leaderId: data.leaderId,
                sortOrder: data.sortOrder || 0,
                status: data.status ?? 1,
            });
            onOpenChange(false);
        } finally {
            setSubmitting(false);
        }
    };

    /**
     * 获取对话框标题
     */
    const getTitle = () => {
        if (isEditMode) return '编辑部门';
        if (parentDepartment) return `新增子部门 - ${parentDepartment.name}`;
        return '新增部门';
    };

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="sm:max-w-120">
                <DialogHeader>
                    <DialogTitle>{getTitle()}</DialogTitle>
                    <DialogDescription>
                        {isEditMode ? '修改部门信息' : '填写新部门的基本信息'}
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 py-4">
                    {/* 部门名称 */}
                    <div className="space-y-2">
                        <Label htmlFor="name">
                            部门名称 <span className="text-destructive">*</span>
                        </Label>
                        <Input
                            id="name"
                            placeholder="请输入部门名称"
                            {...register('name')}
                            disabled={submitting}
                        />
                        {errors.name && (
                            <p className="text-sm text-destructive">{errors.name.message}</p>
                        )}
                    </div>

                    {/* 上级部门 */}
                    <div className="space-y-2">
                        <Label>上级部门</Label>
                        <Select
                            value={String(watchedParentId || 0)}
                            onValueChange={(value) => setValue('parentId', Number(value))}
                            disabled={submitting}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="选择上级部门（可选）" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="0">无（顶级部门）</SelectItem>
                                {(allDepartments || [])
                                    .filter(d => d.id !== department?.id) // 排除自己
                                    .map((dept) => (
                                        <SelectItem key={dept.id} value={String(dept.id)}>
                                            {dept.name}
                                        </SelectItem>
                                    ))}
                            </SelectContent>
                        </Select>
                    </div>

                    {/* 部门负责人 */}
                    <div className="space-y-2">
                        <Label>部门负责人</Label>
                        <Select
                            value={watchedLeaderId ? String(watchedLeaderId) : 'none'}
                            onValueChange={(value) => setValue('leaderId', value === 'none' ? null : Number(value))}
                            disabled={submitting}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder="选择负责人（可选）" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="none">暂无负责人</SelectItem>
                                {(users || []).map((user) => (
                                    <SelectItem key={user.id} value={String(user.id)}>
                                        {user.nickname} ({user.username})
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>

                    {/* 排序序号 */}
                    <div className="space-y-2">
                        <Label htmlFor="sortOrder">排序序号</Label>
                        <Input
                            id="sortOrder"
                            type="number"
                            min={0}
                            placeholder="数字越小越靠前"
                            {...register('sortOrder', { valueAsNumber: true })}
                            disabled={submitting}
                        />
                    </div>

                    <DialogFooter className="pt-4">
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => onOpenChange(false)}
                            disabled={submitting}
                        >
                            取消
                        </Button>
                        <Button type="submit" disabled={submitting || isLoading}>
                            {submitting && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                            {isEditMode ? '保存修改' : '创建部门'}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}

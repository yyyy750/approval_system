package com.approval.service;

import com.approval.dto.DepartmentDTO;
import com.approval.entity.SysDepartment;
import com.approval.vo.DepartmentTreeVO;

import java.util.List;

/**
 * 部门服务接口
 * 提供部门管理相关业务逻辑
 */
public interface DepartmentService {

    /**
     * 获取完整部门树形结构
     *
     * @return 部门树形结构列表（顶级部门）
     */
    List<DepartmentTreeVO> getDepartmentTree();

    /**
     * 获取所有部门列表（平铺）
     *
     * @return 所有部门列表
     */
    List<SysDepartment> getAllDepartments();

    /**
     * 根据ID获取部门详情
     *
     * @param id 部门ID
     * @return 部门实体
     */
    SysDepartment getById(Long id);

    /**
     * 创建部门
     *
     * @param dto 部门信息
     * @return 创建的部门实体
     */
    SysDepartment create(DepartmentDTO dto);

    /**
     * 更新部门
     *
     * @param id  部门ID
     * @param dto 部门信息
     * @return 更新后的部门实体
     */
    SysDepartment update(Long id, DepartmentDTO dto);

    /**
     * 删除部门
     *
     * @param id 部门ID
     */
    void delete(Long id);
}

package com.approval.service.impl;

import com.approval.dto.DepartmentDTO;
import com.approval.entity.SysDepartment;
import com.approval.entity.SysUser;
import com.approval.exception.BusinessException;
import com.approval.mapper.SysDepartmentMapper;
import com.approval.mapper.SysUserMapper;
import com.approval.service.DepartmentService;
import com.approval.vo.DepartmentTreeVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 部门服务实现类
 * 实现部门管理业务逻辑，包括树形结构构建
 */
@Service
@RequiredArgsConstructor
public class DepartmentServiceImpl implements DepartmentService {

    private final SysDepartmentMapper departmentMapper;
    private final SysUserMapper userMapper;

    /**
     * 获取完整部门树形结构
     *
     * @return 部门树形结构列表
     */
    @Override
    public List<DepartmentTreeVO> getDepartmentTree() {
        // 获取所有部门
        List<SysDepartment> allDepartments = departmentMapper.selectList(
                new LambdaQueryWrapper<SysDepartment>()
                        .orderByAsc(SysDepartment::getSortOrder));

        // 获取所有用户用于填充负责人姓名
        List<SysUser> allUsers = userMapper.selectList(null);
        // 使用 HashMap 手动构建，避免 nickname 为 null 时的 NullPointerException
        Map<Long, String> userNameMap = allUsers.stream()
                .collect(Collectors.toMap(
                        SysUser::getId,
                        user -> user.getNickname() != null ? user.getNickname() : user.getUsername(),
                        (a, b) -> a,
                        java.util.HashMap::new));

        // 转换为VO并构建树形结构
        List<DepartmentTreeVO> voList = allDepartments.stream()
                .map(dept -> convertToVO(dept, userNameMap))
                .collect(Collectors.toList());

        // 构建树形结构
        return buildTree(voList, 0L);
    }

    /**
     * 获取所有部门列表（平铺）
     *
     * @return 所有部门列表
     */
    @Override
    public List<SysDepartment> getAllDepartments() {
        return departmentMapper.selectList(
                new LambdaQueryWrapper<SysDepartment>()
                        .orderByAsc(SysDepartment::getSortOrder));
    }

    /**
     * 根据ID获取部门详情
     *
     * @param id 部门ID
     * @return 部门实体
     */
    @Override
    public SysDepartment getById(Long id) {
        SysDepartment department = departmentMapper.selectById(id);
        if (department == null) {
            throw new BusinessException(404, "部门不存在");
        }
        return department;
    }

    /**
     * 创建部门
     *
     * @param dto 部门信息
     * @return 创建的部门实体
     */
    @Override
    @Transactional
    public SysDepartment create(DepartmentDTO dto) {
        // 验证父部门是否存在
        if (dto.getParentId() != null && dto.getParentId() > 0) {
            SysDepartment parent = departmentMapper.selectById(dto.getParentId());
            if (parent == null) {
                throw new BusinessException(400, "父部门不存在");
            }
        }

        // 验证负责人是否存在
        if (dto.getLeaderId() != null) {
            SysUser leader = userMapper.selectById(dto.getLeaderId());
            if (leader == null) {
                throw new BusinessException(400, "指定的负责人不存在");
            }
        }

        // 构建部门实体
        SysDepartment department = SysDepartment.builder()
                .name(dto.getName())
                .parentId(dto.getParentId() != null ? dto.getParentId() : 0L)
                .leaderId(dto.getLeaderId())
                .sortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0)
                .status(dto.getStatus() != null ? dto.getStatus() : 1)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        departmentMapper.insert(department);
        return department;
    }

    /**
     * 更新部门
     *
     * @param id  部门ID
     * @param dto 部门信息
     * @return 更新后的部门实体
     */
    @Override
    @Transactional
    public SysDepartment update(Long id, DepartmentDTO dto) {
        // 获取现有部门
        SysDepartment department = getById(id);

        // 验证父部门是否存在且不能是自己
        if (dto.getParentId() != null && dto.getParentId() > 0) {
            if (dto.getParentId().equals(id)) {
                throw new BusinessException(400, "父部门不能是自己");
            }
            SysDepartment parent = departmentMapper.selectById(dto.getParentId());
            if (parent == null) {
                throw new BusinessException(400, "父部门不存在");
            }
            // 检查是否形成循环
            if (isDescendant(id, dto.getParentId())) {
                throw new BusinessException(400, "不能将部门移动到其子部门下");
            }
        }

        // 验证负责人是否存在
        if (dto.getLeaderId() != null) {
            SysUser leader = userMapper.selectById(dto.getLeaderId());
            if (leader == null) {
                throw new BusinessException(400, "指定的负责人不存在");
            }
        }

        // 更新字段
        department.setName(dto.getName());
        if (dto.getParentId() != null) {
            department.setParentId(dto.getParentId());
        }
        department.setLeaderId(dto.getLeaderId());
        if (dto.getSortOrder() != null) {
            department.setSortOrder(dto.getSortOrder());
        }
        if (dto.getStatus() != null) {
            department.setStatus(dto.getStatus());
        }
        department.setUpdatedAt(LocalDateTime.now());

        departmentMapper.updateById(department);
        return department;
    }

    /**
     * 删除部门
     *
     * @param id 部门ID
     */
    @Override
    @Transactional
    public void delete(Long id) {
        // 检查部门是否存在
        getById(id);

        // 检查是否有子部门
        int childCount = departmentMapper.countByParentId(id);
        if (childCount > 0) {
            throw new BusinessException(400, "该部门下存在子部门，无法删除");
        }

        // 检查是否有员工
        Long userCount = userMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getDepartmentId, id));
        if (userCount > 0) {
            throw new BusinessException(400, "该部门下存在员工，无法删除");
        }

        departmentMapper.deleteById(id);
    }

    /**
     * 将部门实体转换为树形VO
     *
     * @param dept        部门实体
     * @param userNameMap 用户ID到姓名的映射
     * @return 部门树形VO
     */
    private DepartmentTreeVO convertToVO(SysDepartment dept, Map<Long, String> userNameMap) {
        return DepartmentTreeVO.builder()
                .id(dept.getId())
                .name(dept.getName())
                .parentId(dept.getParentId())
                .leaderId(dept.getLeaderId())
                .leaderName(dept.getLeaderId() != null ? userNameMap.get(dept.getLeaderId()) : null)
                .sortOrder(dept.getSortOrder())
                .status(dept.getStatus())
                .createdAt(dept.getCreatedAt())
                .updatedAt(dept.getUpdatedAt())
                .children(new ArrayList<>())
                .build();
    }

    /**
     * 构建树形结构
     *
     * @param voList   所有部门VO列表
     * @param parentId 父部门ID
     * @return 子部门树列表
     */
    private List<DepartmentTreeVO> buildTree(List<DepartmentTreeVO> voList, Long parentId) {
        List<DepartmentTreeVO> result = new ArrayList<>();
        for (DepartmentTreeVO vo : voList) {
            if ((parentId == null && vo.getParentId() == null) ||
                    (parentId != null && parentId.equals(vo.getParentId()))) {
                vo.setChildren(buildTree(voList, vo.getId()));
                result.add(vo);
            }
        }
        return result;
    }

    /**
     * 检查目标部门是否是源部门的后代
     *
     * @param sourceId 源部门ID
     * @param targetId 目标部门ID
     * @return 是否是后代
     */
    private boolean isDescendant(Long sourceId, Long targetId) {
        List<SysDepartment> children = departmentMapper.selectByParentId(sourceId);
        for (SysDepartment child : children) {
            if (child.getId().equals(targetId) || isDescendant(child.getId(), targetId)) {
                return true;
            }
        }
        return false;
    }
}

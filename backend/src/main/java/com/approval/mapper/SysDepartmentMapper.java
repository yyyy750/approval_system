package com.approval.mapper;

import com.approval.entity.SysDepartment;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 部门Mapper接口
 * 提供部门表的数据访问操作
 */
@Mapper
public interface SysDepartmentMapper extends BaseMapper<SysDepartment> {

    /**
     * 根据父部门ID查询子部门列表
     *
     * @param parentId 父部门ID
     * @return 子部门列表
     */
    @Select("SELECT * FROM sys_department WHERE parent_id = #{parentId} ORDER BY sort_order ASC")
    List<SysDepartment> selectByParentId(@Param("parentId") Long parentId);

    /**
     * 查询所有启用状态的部门
     *
     * @return 启用状态的部门列表
     */
    @Select("SELECT * FROM sys_department WHERE status = 1 ORDER BY sort_order ASC")
    List<SysDepartment> selectAllEnabled();

    /**
     * 统计子部门数量
     *
     * @param parentId 父部门ID
     * @return 子部门数量
     */
    @Select("SELECT COUNT(*) FROM sys_department WHERE parent_id = #{parentId}")
    int countByParentId(@Param("parentId") Long parentId);
}

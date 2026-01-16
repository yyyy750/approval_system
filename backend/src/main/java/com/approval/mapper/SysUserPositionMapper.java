package com.approval.mapper;

import com.approval.entity.SysUserPosition;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 用户职位关联 Mapper 接口
 * 继承 MyBatis-Plus 的 BaseMapper，提供基础 CRUD 操作
 */
@Mapper
public interface SysUserPositionMapper extends BaseMapper<SysUserPosition> {

    /**
     * 根据职位ID查询所有拥有该职位的用户ID列表
     * 
     * @param positionId 职位ID
     * @return 用户ID列表
     */
    @Select("SELECT user_id FROM sys_user_position WHERE position_id = #{positionId}")
    List<Long> selectUserIdsByPositionId(@Param("positionId") Long positionId);

    /**
     * 根据职位ID查询第一个拥有该职位的用户ID（优先返回主职位用户）
     * 
     * @param positionId 职位ID
     * @return 用户ID，如果没有找到则返回null
     */
    @Select("SELECT user_id FROM sys_user_position WHERE position_id = #{positionId} ORDER BY is_primary DESC LIMIT 1")
    Long selectFirstUserIdByPositionId(@Param("positionId") Long positionId);
}

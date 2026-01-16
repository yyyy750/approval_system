package com.approval.mapper;

import com.approval.entity.Notification;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

/**
 * 通知Mapper接口
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    /**
     * 将用户所有未读通知标记为已读
     *
     * @param userId 用户ID
     * @return 更新的记录数
     */
    @Update("UPDATE notification SET is_read = 1, read_at = NOW() WHERE user_id = #{userId} AND is_read = 0")
    int markAllAsRead(@Param("userId") Long userId);
}

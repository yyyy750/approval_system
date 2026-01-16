package com.approval.service;

import com.approval.dto.ApprovalTypeRequest;
import com.approval.entity.ApprovalType;

import java.util.List;

/**
 * 审批类型服务接口
 */
public interface ApprovalTypeService {

    /**
     * 获取所有可用的审批类型
     *
     * @return 审批类型列表
     */
    List<ApprovalType> getAvailableTypes();

    /**
     * 获取所有审批类型（包括禁用的）
     *
     * @return 审批类型列表
     */
    List<ApprovalType> getAllTypes();

    /**
     * 根据编码获取审批类型
     *
     * @param code 审批类型编码
     * @return 审批类型
     */
    ApprovalType getByCode(String code);

    /**
     * 根据ID获取审批类型
     *
     * @param id 审批类型ID
     * @return 审批类型
     */
    ApprovalType getById(Long id);

    /**
     * 创建审批类型
     *
     * @param request 创建请求
     * @return 审批类型
     */
    ApprovalType create(ApprovalTypeRequest request);

    /**
     * 更新审批类型
     *
     * @param id      审批类型ID
     * @param request 更新请求
     * @return 审批类型
     */
    ApprovalType update(Long id, ApprovalTypeRequest request);

    /**
     * 删除审批类型
     *
     * @param id 审批类型ID
     */
    void delete(Long id);
}

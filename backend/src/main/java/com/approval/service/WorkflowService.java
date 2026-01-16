package com.approval.service;

import com.approval.dto.WorkflowCreateRequest;
import com.approval.dto.WorkflowUpdateRequest;
import com.approval.vo.WorkflowVO;
import com.baomidou.mybatisplus.core.metadata.IPage;

/**
 * 工作流服务接口
 */
public interface WorkflowService {

    /**
     * 获取工作流列表（分页）
     *
     * @param page     页码
     * @param pageSize 每页条数
     * @param typeCode 类型编码筛选（可选）
     * @param status   状态筛选（可选）
     * @return 分页结果
     */
    IPage<WorkflowVO> getWorkflowList(int page, int pageSize, String typeCode, Integer status);

    /**
     * 获取工作流详情（含节点）
     *
     * @param id 工作流ID
     * @return 工作流详情VO
     */
    WorkflowVO getWorkflowDetail(Long id);

    /**
     * 根据审批类型编码获取工作流
     *
     * @param typeCode 审批类型编码
     * @return 工作流VO
     */
    WorkflowVO getWorkflowByTypeCode(String typeCode);

    /**
     * 创建工作流
     *
     * @param request 创建请求
     * @param userId  创建人ID
     * @return 工作流VO
     */
    WorkflowVO createWorkflow(WorkflowCreateRequest request, Long userId);

    /**
     * 更新工作流
     *
     * @param id      工作流ID
     * @param request 更新请求
     * @return 工作流VO
     */
    WorkflowVO updateWorkflow(Long id, WorkflowUpdateRequest request);

    /**
     * 删除工作流
     *
     * @param id 工作流ID
     */
    void deleteWorkflow(Long id);

    /**
     * 更新工作流状态
     *
     * @param id     工作流ID
     * @param status 状态: 0-禁用 1-启用
     */
    void updateWorkflowStatus(Long id, Integer status);
}

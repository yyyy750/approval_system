package com.approval.controller;

import com.approval.common.Result;
import com.approval.dto.ApprovalTypeRequest;
import com.approval.entity.ApprovalType;
import com.approval.service.ApprovalTypeService;
import com.approval.vo.ApprovalTypeVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 审批类型管理控制器
 * 提供审批类型的 CRUD API
 */
@RestController
@RequestMapping("/api/v1/approval-types")
@RequiredArgsConstructor
@Slf4j
public class ApprovalTypeController {

    private final ApprovalTypeService approvalTypeService;

    /**
     * 获取所有审批类型列表
     *
     * @return 审批类型列表
     */
    @GetMapping
    public Result<List<ApprovalTypeVO>> getAllTypes() {
        List<ApprovalType> types = approvalTypeService.getAllTypes();
        List<ApprovalTypeVO> voList = types.stream()
                .map(ApprovalTypeVO::from)
                .collect(Collectors.toList());
        return Result.success(voList);
    }

    /**
     * 获取单个审批类型详情
     *
     * @param id 审批类型ID
     * @return 审批类型详情
     */
    @GetMapping("/{id}")
    public Result<ApprovalTypeVO> getTypeById(@PathVariable Long id) {
        ApprovalType type = approvalTypeService.getById(id);
        return Result.success(ApprovalTypeVO.from(type));
    }

    /**
     * 创建审批类型
     *
     * @param request 创建请求
     * @return 审批类型
     */
    @PostMapping
    public Result<ApprovalTypeVO> createType(@Valid @RequestBody ApprovalTypeRequest request) {
        ApprovalType type = approvalTypeService.create(request);
        log.info("创建审批类型: {}", type.getName());
        return Result.success(ApprovalTypeVO.from(type));
    }

    /**
     * 更新审批类型
     *
     * @param id      审批类型ID
     * @param request 更新请求
     * @return 审批类型
     */
    @PutMapping("/{id}")
    public Result<ApprovalTypeVO> updateType(
            @PathVariable Long id,
            @Valid @RequestBody ApprovalTypeRequest request) {
        ApprovalType type = approvalTypeService.update(id, request);
        return Result.success(ApprovalTypeVO.from(type));
    }

    /**
     * 删除审批类型
     *
     * @param id 审批类型ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteType(@PathVariable Long id) {
        approvalTypeService.delete(id);
        return Result.success();
    }
}

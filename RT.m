% PDTRTのクラス
classdef RT
    properties
        control
        near
        far
        controlMiss
        nearMiss
        farMiss
    end
    
    methods
        function obj = RT(control, near, far)
            % 引数のバリデーション
            if nargin == 3
                % 刺激の見逃し率計算
                obj.controlMiss = (height(control) - length(rmmissing(control{:, 1}))) / height(control);
                obj.nearMiss = (height(near) - length(rmmissing(near{:, 1}))) / height(near);
                obj.farMiss = (height(far) - length(rmmissing(far{:, 1}))) / height(far);

                obj.control = rmmissing(control{:, 1});
                obj.near = rmmissing(near{:, 1});
                obj.far = rmmissing(far{:, 1});
            else
                error('Arguments for control, near, and fara are required');
            end
        end

        function [controlMiss, nearMiss, farMiss] = getMissingRate(obj)
            controlMiss = obj.controlMiss;
            nearMiss = obj.nearMiss;
            farMiss = obj.farMiss;
        end
    end
end
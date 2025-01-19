l = addlistener(becExp,'NewRunFinished',@(src,event) onChanged(src,event));
function onChanged(~,~)
    disp("yes")
end
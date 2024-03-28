%Created to plot waveform into the KP1Plot and KP2Plot when called.

function buidlPlot_gui(app, whichSource,arbsList,sampleR,repeatsList,playModeIn, selectedTrigButton)


dataList={arbsList{1:end}};
data=[];

for ii=1:length(dataList)
    for jj=1:repeatsList(ii)
        data=[data dataList{ii}];
    end
end

tvals=(1:length(data))/sampleR;

if strcmp(whichSource, "1")
    plot(app.KP1Plot, tvals, data);
end


if strcmp(whichSource, "2")
    plot(app.KP2Plot, tvals, data);
end
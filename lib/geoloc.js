var geoip = require('geoip-lite');

function Point(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
}

module.exports = {
    /*
     * Returns geoloc Point from the requester's ip adress
     * @throws Exception
     */
    getPointfromIp: function(ip) {
        var latitude, longitude;

        var geo = geoip.lookup(ip);

        if (!geo) {
            return null;
        }

        longitude = geo.ll[1];
        latitude = geo.ll[0];

        return new Point(latitude, longitude);
    },
    getCityFromIp: function(ip) {
        return geoip.lookup(ip);
    }
};

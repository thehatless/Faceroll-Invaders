// Generated by CoffeeScript 2.0.3
var hit, risk;

risk = 0;

hit = function(attacker, target) {
  var damage;
  risk += this.risk;
  damage = attacker.strength * attacker.level;
  damage *= Math.random() * 0.2 + 0.9;
  damage = parseInt(damage);
  target.woundHp = target.hp;
  return target.hp -= damage;
};
